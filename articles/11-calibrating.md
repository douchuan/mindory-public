# Calibrating `content_anchor` in RAG Systems  

### Making LLM Citations Precise and Highlightable

In retrieval-augmented generation (RAG) systems, LLMs are often asked to return **exact textual anchors** that point back to the source material.

A typical field looks like this:

```json
"content_anchor": "a continuous, literal substring from the source chunk"
````

This field is critical for:

* precise highlighting
* context expansion
* citation verification

However, in practice, **LLMs frequently produce anchors that are almost correct—but not exact**.

This article presents a **lightweight engine-side calibration strategy** that fixes these errors safely and deterministically.

---

## Why `content_anchor` Fails in Practice

Common failure patterns:

* extra trailing characters
* partial paraphrasing
* hallucinated suffixes
* correct beginning, incorrect ending

These failures are not semantic errors — they are **string precision errors**.

Key observation:

> **The prefix of `content_anchor` is usually correct.
> The suffix is where things go wrong.**

---

## Calibration Design Principle

> **Never invent text. Only verify or truncate.**

The engine:

* may shorten the anchor
* may reject it
* must never rewrite or extend it

---

## Calibration Strategy

### Goal

Ensure that `content_anchor` is:

* a literal substring of the chunk
* continuous
* uniquely matchable
* long enough to be meaningful

---

## Core Algorithm

### Step-by-step Logic

1. Check whether the anchor already exists in the chunk
2. If not, progressively truncate from the **end**
3. Keep the **longest valid prefix** that appears in the chunk
4. Discard if the remaining text is too short

---

## Pseudocode

```pseudo
function calibrateContentAnchor(chunk_text, raw_anchor):
    if raw_anchor is null or empty:
        return null

    if normalize(chunk_text).contains(normalize(raw_anchor)):
        return raw_anchor

    chars = raw_anchor.chars()

    for i from chars.length downTo 1:
        candidate = chars[0..i]
        if normalize(chunk_text).contains(normalize(candidate)):
            if candidate.length >= MIN_ANCHOR_LEN:
                return candidate
            else:
                return null

    return null
```

---

## Safety Guarantees

This algorithm guarantees:

* no fabricated text
* no mid-string extraction
* no false matches
* deterministic results

If calibration fails, the annotation is **discarded**, not guessed.

---

## Practical Impact

After calibration:

* frontend `includes(anchor)` checks succeed
* anchor highlighting becomes reliable
* context lookup becomes stable
* fallback logic is rarely triggered

Most importantly:

> **The system regains determinism without weakening the prompt.**

---

## Observability (Optional but Recommended)

To debug LLM behavior over time, preserve raw values:

```json
{
  "content_anchor": "calibrated text",
  "raw_content_anchor": "llm output",
  "anchor_repair": {
    "status": "truncated",
    "original_length": 18,
    "final_length": 11
  }
}
```

---

## Conclusion

LLMs are good at choosing *what* to cite,
but engines must be responsible for ensuring *where* it lives.

By applying a conservative, prefix-based calibration strategy to `content_anchor`, you can make RAG citations:

* precise
* highlightable
* production-safe

> **Precision is an engineering responsibility, not a modeling one.**
