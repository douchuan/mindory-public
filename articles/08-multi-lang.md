# Multilingual Support in Mindory: Engineering Decisions for AI-Assisted Reading

Mindory is not just a reading app.  
It is an **AI-assisted reading system**, designed to help users *understand, search, and interact with books* more effectively.

This premise matters.

Once AI becomes part of the reading loop—semantic search, quote recall, contextual Q&A—**language handling stops being a UI concern and becomes a core system problem**.

This article focuses on the **engineering perspective** behind Mindory’s multilingual support, under real-world constraints.

---

## 1. AI-Assisted Reading Changes the Problem Space

Traditional reading systems care about:

- Rendering
- Pagination
- Fonts and layout

AI-assisted reading adds new requirements:

- Semantic embeddings of text
- Vector search over book content
- Language-aware prompting
- Consistent semantic quality across languages

In other words:

> The system must *understand* text, not just display it.

Once this is the goal, multilingual support is no longer optional—it is foundational.

---

## 2. Local-First AI Defines the Hard Constraints

Mindory is designed as a **local-first AI system**.

This means:

- All embedding happens locally
- No dependency on cloud GPUs
- Privacy-preserving by default

From an engineering standpoint, we assume:

- CPU-only execution
- Limited memory
- Background indexing alongside active reading

This immediately narrows the solution space.

Any approach that relies on:
- Large multilingual models
- High memory pressure
- Long blocking inference

…will eventually fail in real user environments.

---

## 3. Embedding Models: Small, Language-Specific, Predictable

### Why not a large multilingual embedding model?

In a cloud setting, large multilingual models are attractive.  
In a local AI-assisted reader, they are risky.

Problems include:

- Slow CPU inference
- Unstable latency
- High memory usage
- Poor UX during background indexing

Instead, Mindory adopts **small, language-specific embedding models**.

### Current choices

- `Xenova/bge-small-zh-v1.5` — Chinese books
- `Xenova/bge-small-en-v1.5` — English books

These models:

- Run reliably on CPU
- Have low memory footprints
- Deliver sufficient semantic quality for:
  - Quote search
  - Passage recall
  - Contextual question answering

Larger models remain candidates for experimentation—but only if they justify their resource cost in a local setting.

---

## 4. CPU-Only Embedding Pipeline Design

Without GPU acceleration, embedding becomes an **engineering scheduling problem**.

Key design principles:

- Embedding runs asynchronously
- Reading is never blocked
- Text is processed in bounded chunks
- Indexing is incremental, not monolithic

This ensures:

- Smooth reading experience
- Predictable system behavior
- Graceful handling of large books

AI assistance should feel *ambient*, not intrusive.

---

## 5. Vector Stores Must Follow the Model, Not Assumptions

A common engineering pitfall is hard-coding embedding dimensions:

```text
embedding_dim = 384
````

This works—until models change.

### Problems this causes

* Silent incompatibility when switching models
* Broken re-indexing
* Difficult debugging

### Mindory’s approach

* Embedding dimension is derived from model metadata
* Vector store configuration is generated dynamically
* **Each book owns its own vector store file**

This design enables:

* Safe model upgrades
* Per-book re-indexing
* Failure isolation
* Future multi-model experimentation

---

## 6. Prompting Is Part of Multilingual Infrastructure

In an AI-assisted reader, prompts are not static text.
They are part of the language pipeline.

Engineering considerations:

* Prompts are selected based on book language
* Chinese and English prompts are maintained independently
* Tone, structure, and instructions are language-appropriate

Why this matters:

* Prevents semantic drift
* Improves answer relevance
* Reduces hallucinations caused by language mismatch

Prompts are treated as **versioned system assets**, not inline strings.

---

## 7. Engineering Trade-Offs, Made Explicit

Mindory’s multilingual AI pipeline is built on intentional trade-offs:

| Decision                       | Rationale                        |
| ------------------------------ | -------------------------------- |
| Small language-specific models | Reliable CPU performance         |
| Per-book vector stores         | Isolation and re-indexing safety |
| Dynamic embedding dimensions   | Model flexibility                |
| Language-aware prompts         | Higher semantic quality          |
| Local-only AI processing       | Privacy and predictability       |

These choices prioritize **system stability over theoretical optimality**.

---

## Conclusion

Multilingual support in an AI-assisted reading system is not about adding translation layers or choosing the biggest model.

It is about:

* Treating language as a system parameter
* Designing for limited local resources
* Making AI assistance reliable, not impressive
* Avoiding hidden assumptions

Mindory’s approach focuses on engineering fundamentals first.

By solving these “small” problems correctly, AI-assisted reading becomes practical, extensible, and trustworthy—across languages.
