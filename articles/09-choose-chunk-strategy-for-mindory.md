# Choosing the Right Chunking Strategy for Mindory  
*Why We Deliberately Use Character-Based Chunks for English and Chinese*

---

## 1. Mindory’s Product Premise

**Mindory is not a generic RAG demo.**

It is a **local-first, reading-oriented system** with a very explicit product stance:

- Books, not documents
- Reading, not just Q&A
- Strong linkage between **AI understanding** and **original text**
- Engineering priorities: **determinism, traceability, testability**

This positioning leads to one non-negotiable requirement:

> **Every embedding chunk must be strongly and precisely traceable back to the original text.**

Not approximately.  
Not heuristically.  
But *deterministically*.

This single requirement already rules out many “theoretically better” chunking strategies.

---

## 2. Why Chunking Matters

Chunking exists for one reason only:

> To provide **reasonably sized semantic windows** for embedding models.

Chunking is **not** responsible for:

- Final answer quality  
- User understanding  
- Narrative coherence  

Those responsibilities belong to:
- Retrieval overlap
- Top-k aggregation
- LLM synthesis

This distinction is crucial when evaluating trade-offs.

---

## 3. The Three Common Chunking Strategies

Let’s evaluate three typical approaches **under Mindory’s constraints**, not in abstraction.

---

## 4. Sentence / Word-Based Chunking

### The Idea

- Split text by sentences or words
- Each chunk is “semantically complete”
- Very popular in NLP discussions

### The Hidden Cost

#### 1. Loss of Determinism

Sentence boundaries are *not deterministic* across:

- Writing styles
- Languages
- Quotation, code, poetry
- OCR or imperfect text

Even “simple” English sentence splitting quickly devolves into heuristics.

#### 2. Broken Traceability

Mindory requires a clean mapping:

```

processed_text_char_index → original_text_char_offset

```

Sentence-aware chunking introduces:

- Variable-length chunks
- Non-linear offsets
- Cross-boundary merges and splits

This makes **precise highlighting, navigation, and provenance** significantly harder.

#### 3. False User Benefit

Users never read raw chunks.

They read:
- LLM-generated answers
- Highlighted original text

Sentence purity inside embedding chunks does **not** translate into perceptible UX gains.

### Verdict

- Conflicts with Mindory’s determinism  
- Degrades traceability  
- Increases engineering complexity without user-visible benefit  

---

## 5. Tokenizer-Based Chunking

### The Idea

- Chunk by model tokens instead of characters
- Aligns with how embedding models “see” text
- Often considered academically correct

### The Real Problems

#### 1. Token ≠ Character ≠ Original Text

Tokenizers introduce a new coordinate system:

- Tokens do not map cleanly to characters
- Special tokens, whitespace handling, normalization
- Model-specific behavior

This breaks the clean, monotonic mapping Mindory relies on.

#### 2. Architecture Contamination

Mindory’s design principle:

> **Embedding models are replaceable. Pipelines are stable.**

Token-based chunking reverses this:
- Pipeline becomes model-aware
- Tokenizer choice leaks into ingestion
- Model swapping becomes risky

#### 3. Marginal Practical Gains

In real-world RAG usage:
- Overlap + top-k retrieval
- LLM synthesis dominates final quality

Tokenizer precision rarely produces noticeable user improvements at the product level.

### Verdict

- Breaks strong text traceability  
- Couples ingestion to models  
- High cost, low perceptible gain  

---

## 6. Character-Based Chunking (Mindory’s Choice)

### The Idea

- Fixed-size sliding window over Unicode characters
- Language-agnostic (only chars for zh/en)
- Simple overlap

### Why It Works So Well for Mindory

#### 1. Perfect Traceability

Character offsets are:

- Stable
- Language-neutral
- Directly mappable to original text

This enables:
- Accurate highlighting
- Reliable navigation
- Trustworthy citations

#### 2. Deterministic Behavior

Same input → same chunks  
No heuristics. No NLP ambiguity.

This is invaluable for:
- Testing
- Debugging
- Long-term maintenance

#### 3. “Good Enough” Semantics

Embedding models do not require:
- Sentence-perfect boundaries
- Linguistic purity

They require:
- Sufficient context
- Reasonable length
- Overlap continuity

Character-based chunking satisfies all three.

---

## 7. Does This Hurt Understanding?

Short answer: **No.**

Longer answer:

- Retrieval uses multiple chunks
- Overlap smooths boundary cuts
- LLM reconstructs meaning holistically

Users do not perceive chunk boundaries.  
They perceive **answers and highlighted passages**.

As long as chunks are:
- Not too short
- Not isolated
- Properly overlapped

The semantic impact is negligible.

---

## 8. Conclusion

Mindory’s chunking strategy is not a shortcut.  
It is a **deliberate engineering decision** aligned with:

- Product goals
- UX integrity
- Architectural cleanliness

> **In Mindory, correctness means traceability.  
> Intelligence comes later.**