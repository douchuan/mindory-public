# Mindory Architecture & Asynchronous Design

## Overview

Mindory is a Chinese-friendly reading app with LLM-based content understanding. Key features:

- Rust full-stack (backend + Tauri frontend)
- Asynchronous ingestion, RAG, LLM inference
- Event-driven task notifications for the frontend
- High engineering quality: full unit & integration testing

## Architecture

# Mindory Architecture & Asynchronous Design

## Overview

Mindory is a Chinese-friendly reading app with LLM-based content understanding. Key features:

- Rust full-stack (backend + Tauri frontend)
- Asynchronous ingestion, RAG, LLM inference
- Event-driven task notifications for the frontend
- High engineering quality: full unit & integration testing

## Architecture

```mermaid
graph TD
    subgraph Frontend [Tauri Frontend]
        UI[User Interface]
        EventListener[Event Listener]
    end

    subgraph Backend [Rust Async Backend]
        AsyncIngestRunner[AsyncIngestRunner]
        BookStore[BookStore]
        RAGPipeline[RAG Pipeline]
        EmbeddingEngine[Embedding Engine]
        LLMClient[LLM Client]
        VectorStore[Vector Store Factory]
        DB[SQLite / Repository]
    end

    UI -->|User actions| AsyncIngestRunner
    AsyncIngestRunner -->|Tasks & Updates| BookStore
    AsyncIngestRunner --> RAGPipeline
    RAGPipeline --> EmbeddingEngine
    RAGPipeline --> VectorStore
    RAGPipeline --> LLMClient
    BookStore --> DB
    EventListener -->|app::ingestbook| UI
```

**Components**:

- **Tauri Frontend**: UI & event subscription
- **AsyncIngestRunner**: manages ingestion tasks asynchronously
- **BookStore**: in-memory & DB book state
- **RAG Pipeline**: retrieval-augmented generation
- **Embedding Engine**: vector embedding for documents

## Features

- Multi-format support (TXT, EPUB, PDF)
- Real-time ingestion status updates
- Low latency, small installation package
- Full async runtime using Tokio + Tauri async runtime

## Example

```rust
let _task_id = book_store
    .add_book_and_ingest::<PdfParser>(
        source_info,
        text_pipeline,
        embedding_engine.clone(),
        vector_store_factory.clone(),
    )
    .await;
```