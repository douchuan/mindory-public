# Text Segmentation and Multi-Format Support in Mindory

## Introduction

Building an LLM-powered reading assistant like Mindory requires robust handling of diverse document formats. Users may read **TXT, PDF, EPUB**, or other formats, and ask questions across large collections of books. To support this, Mindory introduces a **text pipeline abstraction** that:

- Segments text into meaningful chunks
- Handles multiple document formats
- Feeds the text to embedding models and vector stores
- Maintains high performance and asynchronous operation

This article explores the design and implementation of Mindory's text ingestion and multi-format abstraction.

---

## Multi-Format Abstraction

Mindory represents each document as a **SourceInfo**:

```rust
pub struct SourceInfo {
    pub uri: String,           // File path or URL
    pub name: String,          // Filename or identifier
    pub format: DocumentFormat,// Txt, Pdf, Epub, etc.
    pub title: Option<String>,
    pub author: Option<String>,
}
````

**DocumentFormat** enum allows polymorphic handling:

```rust
pub enum DocumentFormat {
    Txt,
    Pdf,
    Epub,
    // Extendable for future formats
}
```

### Parser Abstraction

Each format has a corresponding parser implementing the `Parser` trait:

```rust
pub trait Parser {
    fn parse(&self, source: &SourceInfo) -> anyhow::Result<String>;
}
```

* `TxtParser`: reads plain text files, handles encoding issues
* `PdfParser`: extracts text from PDF pages
* `EpubParser`: extracts text from EPUB chapters
* Parsers return a unified string, allowing downstream pipeline to remain **format-agnostic**

---

## Text Segmentation

To prepare documents for **embedding and RAG**, Mindory segments text:

* **Chunk size**: configurable (e.g., 1000 characters)
* **Chunk stride**: overlap between chunks to preserve context (e.g., 200 characters)
* **Context-aware splitting**: attempts to split at sentence or paragraph boundaries

```rust
pub struct TextPipeline {
    pub chunk_size: usize,
    pub chunk_stride: usize,
}

impl TextPipeline {
    pub fn new(chunk_size: usize, chunk_stride: usize) -> Self {
        Self { chunk_size, chunk_stride }
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
            start += self.chunk_size.saturating_sub(self.chunk_stride);
        }

        chunks
    }
}
```

**Benefits:**

* Preserves semantic coherence across overlapping chunks
* Works across TXT, PDF, EPUB uniformly
* Enables **efficient embedding and retrieval**

---

## Async Ingestion Pipeline

Mindory's **AsyncIngestRunner** orchestrates multi-format ingestion:

1. Determine the parser from `DocumentFormat`
2. Parse document to plain text
3. Segment text into chunks
4. Embed chunks into vector store
5. Update task status asynchronously

```rust
let parser: Arc<dyn Parser> = match source.format {
    DocumentFormat::Txt => Arc::new(TxtParser {}),
    DocumentFormat::Pdf => Arc::new(PdfParser {}),
    DocumentFormat::Epub => Arc::new(EpubParser {}),
};

let text = parser.parse(&source)?;
let chunks = text_pipeline.segment(&text);
```

* Fully asynchronous using `tokio`
* Multiple ingestion tasks can run concurrently without blocking UI
* Status updates pushed to frontend via events (`app::ingestbook`)

---

## Advantages of This Design

* **Format-agnostic pipeline**: adding new formats only requires a new parser
* **Consistent chunking**: embeddings and retrieval logic do not depend on format
* **High performance**: uses Rust’s async runtime for parallel ingestion
* **Scalable**: supports thousands of books, multiple concurrent tasks
* **Easy integration**: vector stores and embedding engines are pluggable

---

## Future Directions

* Advanced semantic segmentation (sentence embeddings for smarter chunking)
* Handling **scanned PDFs** with OCR integration
* Support for **web articles** and online resources
* Dynamic pipeline configuration per document type