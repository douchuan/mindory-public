# Mindory 中的文本分割与多格式支持：打造灵活高效的阅读助手
## 引言
构建像 Mindory 这样基于大语言模型（LLM）的阅读助手，核心挑战之一是对多样化文档格式的稳健处理。用户可能阅读 TXT、PDF、EPUB 等不同格式的书籍，并针对大部头书籍提问 —— 为满足这一需求，Mindory 设计了一套**文本流水线抽象层**，实现了以下核心能力：
- 将文本切分为语义完整的片段
- 兼容多类文档格式的解析处理
- 为 embedding 和向量数据库提供标准化文本输入
- 全程保持高性能与异步运行特性

本文将深入解析 Mindory 文本导入流程与多格式抽象层的设计思路和实现方案。

---

## 多格式抽象设计
Mindory 将每一份文档抽象为 `SourceInfo` 结构体，统一管理文档核心信息：

> **Note**：为提升模型回答准确性，title 和 author 是必填项目

```rust
pub struct SourceInfo {
    pub uri: String,           // 文件路径或网络地址
    pub name: String,          // 文件名或唯一标识
    pub format: DocumentFormat,// 格式类型（Txt/Pdf/Epub等）
    pub title: String,          // 文档标题
    // pub title: Option<String>,
    pub author: String,         // 文档作者
    // pub author: Option<String>,
}
```

通过`DocumentFormat`枚举类型，实现对不同格式的多态处理，且预留了扩展空间：

```rust
pub enum DocumentFormat {
    Txt,
    Pdf,
    Epub,
    // 可扩展支持更多格式
}
```

### 解析器抽象层
每种文档格式都对应一个实现了 `Parser` trait 的解析器，保证解析逻辑接口统一:

```rust
pub trait Parser {
    fn parse(&self, source: &SourceInfo) -> anyhow::Result<String>;
}
```

- **TxtParser**：解析纯文本格式
- **PdfParser**：解析 PDF 文档格式
- **EpubParser**：解析 EPUB 电子书格式
- 所有解析器最终返回统一的 UTF-8 字符流，让下游 ( chunk / embedding ) 实现**格式无关化**处理

---

## 文本分割策略
为适配 Embedding Model 和 RAG 召回需求，Mindory 对解析后的文本进行精细化分割：
- **chunk 长度**：可配置（ 例如 1000 字符 ）
- **overlap**：上下文 overlap 区域（ 例如 200 字符 ），保证语义连贯

```rust
pub struct TextPipeline {
    pub chunk_size: usize,
    pub overlap: usize,
}

impl TextPipeline {
    pub fn new(chunk_size: usize, overlap: usize) -> Self {
        Self { chunk_size, overlap }
    }

    pub fn segment(&self, text: &str) -> Vec<String> {
        let mut chunks = Vec::new();
        let mut start = 0;
        let text_chars: Vec<char> = text.chars().collect();
        let total_len = text_chars.len();

        while start < total_len {
            let end = (start + self.chunk_size).min(total_len);
            let chunk: String = text_chars[start..end].iter().collect();
            chunks.push(chunk);
            start += self.chunk_size.saturating_sub(self.overlap);
        }

        chunks
    }
}
```

**核心优势**：
- overlap 片段设计保障语义连贯性，避免关键信息割裂
- 对 TXT、PDF、EPUB 等格式实现统一的分割逻辑
- 为后续**高效 embedding 计算和精准检索**奠定基础

---

## 异步导入流水线
Mindory 的 `AsyncIngestRunner` 组件统筹多格式文档的导入流程，核心步骤如下：
1. 根据 `DocumentFormat` 匹配对应的解析器
2. 将文档解析为纯文本
3. 对文本进行分段处理
4. 将文本片段 embedding 并写入向量数据库
5. 异步更新任务状态，实时反馈进度

```rust
// 根据文档格式动态选择解析器
let parser: Arc<dyn Parser> = match source.format {
    DocumentFormat::Txt => Arc::new(TxtParser {}),
    DocumentFormat::Pdf => Arc::new(PdfParser {}),
    DocumentFormat::Epub => Arc::new(EpubParser {}),
};

// 解析+分段核心逻辑
let text = parser.parse(&source)?;
let chunks = text_pipeline.segment(&text);
```

- 基于 `tokio` 实现全异步化处理
- 多份文档的导入任务可并发执行，完全不阻塞 UI 界面
- 通过 `app::ingestbook` 事件将进度状态推送到前端，实现实时刷新

---

## 该设计方案的核心优势
- **格式无关化流水线**：新增格式仅需实现对应的解析器，无需修改下游逻辑
- **统一分段策略**：embedding 和检索逻辑不依赖文档格式，保证处理一致性
- **高性能处理**：借助 Rust 异步运行时实现并行导入，效率远超同步处理
- **高可扩展性**：支持数本书的批量处理，兼容多任务并发执行
- **易集成扩展**：向量数据库和 embedding 引擎支持插件化替换，灵活适配不同需求