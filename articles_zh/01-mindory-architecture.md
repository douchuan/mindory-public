# Mindory 架构设计与异步系统实践

## 1. 概览

Mindory 是一款**面向书籍阅读场景、内置大模型理解能力的本地阅读应用**。

它并不只是“电子书阅读器”，而是试图探索：

> 如何在本地、低功耗和资源受限的环境下，把 AI 用起来？

围绕这个目标，Mindory 在架构层面做了一系列明确且克制的设计选择，核心特性包括：

- **Rust 全栈实现**（后端 + Tauri 桌面前端）
- **全链路异步架构**：书籍导入、RAG 构建、LLM 推理
- **事件驱动的前后端通信模型**
- **高工程质量**：完善的单元测试与集成测试体系

---

## 2. 整体架构设计

Mindory 的架构可以概括为一句话：

> 前端只关心“发生了什么”，后端负责“事情怎么完成”。

### 2.1 系统架构图

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
````

---

## 3. 核心组件说明

### 3.1 Tauri 前端

* 提供阅读与交互界面
* 通过事件机制订阅后台状态变化
* **不直接参与计算逻辑**

前端只负责一件事：
**把系统当前的状态，准确地呈现给用户**。

---

### 3.2 AsyncIngestRunner（异步导入调度器）

这是整个系统的“中枢”。

它负责：

* 接收用户的“添加书籍”请求
* 启动异步导入任务
* 串联解析、embedding、向量存储等步骤
* 向前端持续发送任务进度与状态事件

关键设计原则是：

> 所有耗时操作，都必须异步；
> 阅读体验，永远不能被阻塞。

---

### 3.3 BookStore（书籍状态管理）

BookStore 同时维护：

* **内存中的书籍状态**
* **持久化数据库（SQLite）中的元信息**

它既是状态中心，也是前后端之间的“事实源”。

---

### 3.4 RAG Pipeline（检索增强生成流水线）

这是 AI 辅助阅读的核心链路，负责：

* 文本切分
* 语义 embedding
* 向量检索
* 与 LLM 交互生成回答

Mindory 并不追求“模型越大越好”，而是强调：

> 在本地环境下，可控、稳定、可解释的 AI 行为。

---

### 3.5 Embedding Engine

* 针对中英文分别选择合适的小模型
* 运行在 **CPU-only 环境**
* 适配不同模型的 embedding 维度

Embedding 不再是“顺手一调”的参数，而是系统能力的一部分。

---

## 4. 系统特性总结

Mindory 的一些关键工程特性：

* 支持多种文本格式：TXT / EPUB / PDF
* 书籍导入过程**实时反馈**
* 启动快、安装包小，适合桌面环境（未来会移植到手机和电纸书）
* 基于 Tokio + Tauri 的完整异步运行时

这些看似“基础”的特性，实际上决定了 AI 能否真正融入阅读流程。

---

## 5. 一个真实的使用示例

下面是一段真实的后端调用代码，展示了 Mindory 如何以**类型安全 + 异步方式**完成书籍导入与处理：

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

这段代码背后发生的事情包括：

* 启动异步导入任务
* 解析 PDF 内容
* 构建向量索引
* 向前端持续推送状态事件

而这一切，对用户来说是 **无阻塞** 的。

---

## 6. 结语

Mindory 的架构设计时刻围绕一个非常现实的问题：

> 如何在低功耗环境下，实现 AI 辅助阅读？

异步设计、事件驱动、清晰的模块边界，让系统在复杂度不断上升的同时，仍然保持可维护性。

很多“阅读体验”的提升，其实始于这些不那么显眼的工程细节。

而这，正是 Mindory 想认真解决的事情。