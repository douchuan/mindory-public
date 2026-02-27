# The “Small” Problems You Cannot Ignore When Building a Reading System

When building a reading system — whether for **book readers, ingestion pipelines, search engines, or embedding systems** — the most underestimated problems are often not algorithms or models, but two deceptively “small” issues:

1. **Character encoding (GBK / GB18030 / UTF-8)**
2. **Text formats (TXT / EPUB / MOBI / PDF)**

These problems sit at the very bottom of the system, yet if handled incorrectly, they can silently corrupt data or crash the entire pipeline. This article summarizes a **practical, production-oriented approach** to dealing with them.

---

## 1. Character Encoding: The World Is Not UTF-8

### 1.1 A Reality Check

In real-world book collections:

- Many Chinese books are encoded in:
  - GBK
  - GB2312
  - GB18030
- A large number of files:
  - **Do not declare their encoding**
  - **Declare it incorrectly**
- Some books even mix encodings across chapters

Any system that **assumes all input is valid UTF-8** will inevitably face one of two outcomes:

- The program panics or crashes
- Data is silently corrupted (which is worse)

---

### 1.2 Core Principles for Encoding Handling

#### Principle 1: Raw Bytes Must Be Contained at the System Boundary

> **Invalid encodings must be handled as close to I/O as possible.**

In practice:

- Upper layers (parser / ingest / chunking / embedding):
  - **Must only see valid UTF-8**
- Lower layers (importer / decoder):
  - Absorb all messy, unsafe input

This separation is not optional — it is a **stability guarantee**.

---

#### Principle 2: Encoding Detection Is Not Arbitrary

Encoding detection must follow a **strict order**, not “try until something works”.

A proven strategy:

```

Strict → Semi-self-describing → Lenient → Fallback

```

A practical decoding order:

1. **UTF-8 (strict validation)**
2. **GBK (fail fast if invalid)**
3. **GB18030 (national-level superset)**
4. **UTF-8 lossy decoding (final fallback)**

Why this works:

- UTF-8 is **self-validating**
- GBK is **not self-describing**
- GB18030 has the widest coverage
- Lossy UTF-8 ensures the system never crashes

---

#### Principle 3: Lossy Decoding Is Not Failure

Many systems treat lossy decoding as an error. In reading systems, this is unrealistic.

In practice:

- Minor character loss ≪ system instability
- For search / embedding:
  - **Semantic continuity > byte-level perfection**

Correct mindset:

> **Lossy decoding is a fallback, not the default.**

---

### 1.3 An Important Detail: GBK Is Not Self-Describing

A key issue with GBK / GB2312:

- Many byte sequences are *technically valid*
- But cannot be reliably validated for correctness

This means:

- “Successful” GBK decoding does **not guarantee correctness**
- GB18030 must exist as a broader safety net

This is why GBK should be treated cautiously and never as a final authority.

### 1.4 Codec Pipeline Implementation

```rust
/// 构建默认的编码探测流水线
pub fn default() -> Self {
    Self {
        decoders: vec![
            Box::new(Utf8Decoder),
            Box::new(GbkDecoder),
            Box::new(Gb18030Decoder),
        ],
    }
}

/// 对输入字节进行编码探测与解码
pub fn decode(&self, input: &[u8]) -> DecodedText {
    // 第一阶段：严格 / 保守的编码探测
    for d in &self.decoders {
        if let Some(t) = d.decode(input) {
            return t;
        }
    }

    // 第二阶段：兜底抢救（保证永远返回）
    let (cow, _, _) = UTF_8.decode(input);
    DecodedText {
        text: cow.to_string(),
        encoding: Some("utf-8".into()),
        had_lossy: true,
    }
}
```

---

## 2. Text Formats: Format Is Not Content

### 2.1 What Formats Really Are

| Format | What It Actually Is |
|------|---------------------|
| TXT  | Raw byte stream |
| EPUB | ZIP archive + XHTML |
| MOBI | Proprietary binary structure |
| PDF  | Page rendering instructions |

Their only commonality:

> **Eventually, all of them must become text.**

---

### 2.2 A Key Engineering Decision

> **A v1 reading system does not need to preserve full structural formatting.**

Why:

- For search, embedding, and AI reading:
  - **Content matters more than layout**
- Early structural preservation leads to:
  - Exploding importer complexity
  - Tight coupling between ingest and formats

A pragmatic approach:

> **Decode format → extract content → normalize to UTF-8**

---

### 2.3 Recommended Architecture

A clean, extensible pipeline:

```

[ Raw Bytes ]
↓
[ FormatDecoder ]   ← TXT / EPUB / MOBI / PDF
↓
[ EncodingPipeline ] ← GBK / GB18030 / UTF-8
↓
[ UTF-8 Byte Stream ]
↓
[ Parser / Ingest / Chunk / Search ]

```

Key properties:

- Format decoding and encoding decoding are **orthogonal**
- The importer outputs:
  - Valid UTF-8
  - A continuous byte stream
- Upper layers are completely unaware of:
  - Encoding
  - File type

---

### 2.4 What About EPUB / PDF Structure?

This is a **deliberately postponed problem**.

The strategy:

- v1:
  - Ensure **readability, searchability, and robustness**
- v2+:
  - Enhance structure at the `FormatDecoder` level
  - Without breaking the UTF-8 stream contract

In other words:

> **The importer interface stays stable; capabilities evolve.**

---

## 3. The Minimum Bar for a Mature Reading System

If your system can guarantee:

- No crashes on arbitrary encodings
- UTF-8 everywhere beyond the importer
- Ingest and embedding are format-agnostic
- Lossy cases are controlled and observable

Then you are already ahead of many production-grade systems.

---

## Conclusion

Character encoding and text formats are **not minor implementation details** — they are the foundation of any reading system.

- The earlier encoding is normalized, the more stable the system
- The more restrained format handling is, the easier the system evolves

An engineer’s summary:

> **The first principle of a reading system is not “understanding text”,  
> but “never letting text break the system”.**

This is one of those problems worth solving once — and solving correctly.
