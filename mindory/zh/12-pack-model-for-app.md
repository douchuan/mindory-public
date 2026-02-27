# 给 Tauri 应用打包 Embedding Model: 解决离线部署与用户体验难题

## 引言

在开发搭载 RAG 能力的桌面应用时（ 涉及文本 Embedding 的场景 ），Embedding Model 的可靠分发往往是个棘手问题。本文记录了 Tauri 应用打包 Embedding Model 的实战经验，既能避开运行时下载的坑，又能保障丝滑的用户体验。

## 为什么要这么做？
Embedding Model 体积通常不小（ 动辄超100 MB ），常规做法是在应用运行时从 Hugging Face 或 GitHub 下载，但这种方式存在不少弊端：

* 网络环境差、受限的用户可能下载失败
* 模型下载过程会导致应用启动延迟
* 若源站模型频繁更新，版本管理会变得一团糟

为解决这些问题，我们的核心目标是——**把模型和应用打包在一起**，在用户首次启动时完成本地安装。

---

## 踩过的那些坑

### 1. 模型结构的兼容性问题
这些模型最初是从 Hugging Face 下载的 ( hf download )，但 `fastembed-rs` 库**并不兼容标准的 HF 下载结构**，它要求模型遵循自身的缓存目录格式。这就意味着打包前必须先调整目录结构：

```
embedding/
├── models--Xenova--bge-small-en-v1.5
└── models--Xenova--bge-small-zh-v1.5
```

打包时必须完整保留这个结构，才能让 `fastembed-rs` 正确加载模型。

---

### 2. 大文件解压导致 UI 卡顿
模型文件动辄超 100 MB，直接在主线程解压会让界面明显卡死。为避免这种情况，Mindory 采用了这些策略：

* 借助`tokio::task::spawn_blocking`实现**异步解压**，把解压任务从主线程剥离
* 通过 Tauri 的消息机制，向前端实时推送安装进度
* 采用**临时目录**保证安装的原子性: 先解压到临时文件夹，完成后再重命名为最终路径

这套方案能确保模型安装过程中，应用界面始终保持响应状态。

---

### 3. 模型版本管理
打包的模型在后续版本中可能会更新，要做好版本管控:

* 为每个版本的压缩包计算 **SHA256 校验和**
* 应用启动时，校验已安装模型的 SHA256 值是否与预期一致
* 若 SHA256 值不匹配，就解压新版压缩包完成模型升级
* 本地存储 SHA256 值，供后续版本校验使用

这样既避免了不必要的重装，也能保证用户始终使用正确版本的模型。

---

### 4. Deterministic Packaging: GNU tar vs BSD tar
还有一个看似细微却至关重要的问题——**构建的确定性**。

生成 `models.tar.gz` 时，即便模型文件完全相同，不同系统打包出的二进制文件也可能不一样。究其原因，主要是：

* 文件排序不同
* 时间戳（mtime）不同
* UID/GID 元数据不同
* 不同 `tar` 工具的行为存在差异

macOS 系统默认的 `tar` 是BSD tar，它 **不支持 `--sort=name` 这类确定性参数**。

要让不同环境下生成的 SHA256 值保持一致，就得用 **GNU tar（`gtar`）** 替代 BSD tar。

确定性打包的示例命令：

```bash
gtar \
  --sort=name \
  --mtime='UTC 1970-01-01' \
  --owner=0 --group=0 --numeric-owner \
  -czf models.tar.gz \
  -C ~/.mindory/embedding .
```

接着生成校验和：

```bash
sha256sum models.tar.gz > models.tar.gz.sha256
```

这么做的意义在于：

* 确保不同构建环境输出的 models.tar.gz 文件完全一致
* 让 SHA256 值保持稳定
* 避免模型被无意义地重复安装
* 提升版本发布的可复现性

---

## 完整打包流程

1. **开发环境的模型目录**

```
~/.mindory/embedding/
```

2. **生成确定性压缩包**

```bash
gtar \
    --sort=name \
    --mtime='UTC 1970-01-01' \
    --owner=0 --group=0 --numeric-owner \
    -czf models.tar.gz \
    -C ~/.mindory/embedding .
```

3. **生成SHA256校验和**

```bash
sha256sum models.tar.gz > models.tar.gz.sha256
```

4. **复制到Tauri资源目录**

```
mindory-app/src-tauri/resources/models.tar.gz
mindory-app/src-tauri/resources/models.tar.gz.sha256
```

5. **应用启动时异步安装**

---

## 异步安装示例（Rust核心代码）

```rust
async fn ensure_models_installed(app: AppHandle) -> anyhow::Result<()> {
    let target_dir = get_home_embedding_path()?;
    let tar_path = resolve_resource_path(&app)?;
    let sha_path = tar_path.with_extension("sha256");

    ensure_models_installed_impl(target_dir, tar_path, sha_path).await
}

async fn ensure_models_installed_impl(
    target_dir: PathBuf,
    tar_path: PathBuf,
    sha_path: PathBuf,
) -> anyhow::Result<()> {
    tokio::fs::create_dir_all(&target_dir).await?;

    // 防止并发安装
    let _lock = acquire_install_lock(&target_dir).await?;

    // 版本匹配则跳过安装
    if sha_matches(&target_dir, &sha_path).await? {
        return Ok(());
    }

    let tmp_dir = target_dir.with_extension("tmp");
    tokio::fs::create_dir_all(&tmp_dir).await?;

    // 在阻塞线程中解压
    tokio::task::spawn_blocking(move || {
        let file = std::fs::File::open(&tar_path)?;
        let decoder = GzDecoder::new(file);
        let mut archive = Archive::new(decoder);
        archive.unpack(&tmp_dir)?;
        Ok::<_, anyhow::Error>(())
    })
    .await??;

    verify_sha256(&tar_path, &sha_path).await?;
    atomic_replace(&tmp_dir, &target_dir).await?;

    Ok(())
}
```

---

## 最终实现的优势

* **离线可用**：无需运行时下载模型
* **不受网络限制**：规避受限环境下的下载失败问题
* **界面流畅**：异步解压避免界面阻塞
* **版本可靠**：SHA256 校验保障模型完整性
* **构建可复现**：GNU tar 实现确定性打包
* **更新原子化**：不会出现安装不完整或损坏的情况

---

## 总结
将嵌入模型直接打包到 Tauri 应用中，能大幅提升应用的可靠性和用户体验。只要结合这几点：

* 适配 `fastembed-rs` 的缓存目录结构
* 异步安装流程
* 基于 SHA256 的版本管控
* 用 GNU tar 实现确定性打包

就能打造出一款健壮、支持离线使用的 RAG 桌面应用。

这套方案不仅适用于嵌入模型，还能推广到任何需要分发大文件资源的场景。