# Packaging Embedding Models for Tauri Apps

When developing AI-powered desktop applications, such as those using text embeddings, distributing the models reliably can be challenging. In this post, I document my experience packaging embedding models alongside a Tauri app, avoiding runtime downloads, and ensuring a smooth user experience.

## Motivation

Embedding models can be large (often >100 MB) and are typically downloaded at runtime from Hugging Face or GitHub. This approach has some drawbacks:

* Users with poor or restricted network environments may fail to download models.
* Startup may be delayed while models download.
* Version management becomes complicated if models update frequently.

To solve these issues, the goal is to **bundle the models with the app** and install them locally at first run.

---

## Challenges Encountered

### 1. Model Structure Compatibility

The models were originally downloaded from Hugging Face. However, the `fastembed-rs` library does **not use the standard HF download structure**. It expects models to follow its own cache layout. This required transforming the directory structure before packaging:

```
embedding/
├── models--Xenova--bge-small-en-v1.5
└── models--Xenova--bge-small-zh-v1.5
```

Packaging had to preserve this structure so that `fastembed` could load models correctly.

---

### 2. Large File Sizes and UI Blocking

Models often exceed 100 MB. Directly unpacking them on the main thread causes noticeable UI freezes. To avoid this, the following strategies were used:

* **Asynchronous unpacking** using `tokio::task::spawn_blocking` to offload decompression.
* **Tauri messaging** to notify the frontend of installation progress.
* **Temporary directories** to ensure atomic installation: unpack into a temp folder, then rename to the final path once complete.

This approach keeps the UI responsive while models are being installed.

---

### 3. Model Versioning

Bundled models may be updated in future releases. To manage versions:

* Compute a **SHA256 checksum** for each release tarball.
* At startup, check if the installed model's SHA matches the expected SHA.
* If the SHA differs, upgrade the model by unpacking the new tarball.
* Store the SHA locally for future version checks.

This prevents unnecessary reinstallation and ensures users always have the correct model version.

---

### 4. Deterministic Packaging (GNU tar vs BSD tar)

One subtle but important issue is **deterministic builds**.

When generating `models.tar.gz`, different systems may produce different binary outputs even if the model files are identical. This usually happens because:

* File ordering differs
* Timestamps (mtime) differ
* UID/GID metadata differ
* Different `tar` implementations behave differently

On macOS, the default `tar` is BSD tar, which does **not support some deterministic flags** like `--sort=name`.

To ensure consistent SHA256 values across environments, use **GNU tar (`gtar`)** instead of BSD tar.

Example deterministic packaging command:

```bash
gtar \
  --sort=name \
  --mtime='UTC 1970-01-01' \
  --owner=0 --group=0 --numeric-owner \
  -czf models.tar.gz \
  -C ~/.mindory/embedding .
```

Then generate the checksum:

```bash
sha256sum models.tar.gz > models.tar.gz.sha256
```

Why this matters:

* Ensures identical tar.gz output across builds
* Keeps SHA256 stable
* Prevents unnecessary model reinstallations
* Improves release reproducibility

On macOS, GNU tar can be installed via:

```bash
brew install gnu-tar
```

It will typically be available as `gtar`.

---

## Packaging Workflow

1. **Development Model Directory**

   ```
   ~/.mindory/embedding/
   ```

2. **Create deterministic tarball**

   ```bash
   gtar \
     --sort=name \
     --mtime='UTC 1970-01-01' \
     --owner=0 --group=0 --numeric-owner \
     -czf models.tar.gz \
     -C ~/.mindory/embedding .
   ```

3. **Generate SHA256**

   ```bash
   sha256sum models.tar.gz > models.tar.gz.sha256
   ```

4. **Copy to Tauri resources**

   ```
   mindory-app/src-tauri/resources/models.tar.gz
   mindory-app/src-tauri/resources/models.tar.gz.sha256
   ```

5. **Install asynchronously at startup**

---

## Async Installation Example (Rust Skeleton)

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

    // Prevent concurrent installs
    let _lock = acquire_install_lock(&target_dir).await?;

    // Skip if version matches
    if sha_matches(&target_dir, &sha_path).await? {
        return Ok(());
    }

    let tmp_dir = target_dir.with_extension("tmp");
    tokio::fs::create_dir_all(&tmp_dir).await?;

    // Decompress in blocking thread
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

## Benefits

* **Offline-ready**: No runtime downloads required.
* **Network-independent**: Avoids failures in restricted environments.
* **Responsive UI**: Async unpacking prevents blocking.
* **Version-safe**: SHA256 guarantees integrity.
* **Deterministic builds**: GNU tar ensures reproducible archives.
* **Atomic updates**: No partial or corrupted installations.

---

## Conclusion

Bundling embedding models directly with a Tauri app significantly improves reliability and user experience. By combining:

* Proper cache structure handling (`fastembed-rs`)
* Asynchronous installation
* SHA-based version control
* Deterministic packaging with GNU tar

you can build a robust, offline-ready AI desktop application.

This approach is broadly applicable to any large asset distribution scenario—not just embedding models.