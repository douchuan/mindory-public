## How Mindory Locates Quotes in the Original Text

One of Mindory’s core promises is simple:

> **Every AI-generated quote must point back to the exact place in the book.**

This sounds easy, but in practice it requires a clear and reliable **positioning model** between:

- **Embedding chunks** (used by AI)
- **Render blocks** (used by the reading UI)

---

## 1. The Two Worlds in Mindory

Mindory works with two different but connected views of the same book.

### Embedding World (for AI)

- Text is split into **embedding chunks**
- Each chunk:
  - Has a fixed size
  - Has a clear position in the processed text
  - Is used for semantic search

Think of chunks as **search units**.

---

### Reading World (for Users)

- Text is split into **render blocks**
- Each block:
  - Matches what users read on screen
  - Has a stable order (block index)
  - Can be paged, highlighted, and navigated

Think of render blocks as **reading units**.

---

## 2. The Key Design Rule

Both chunks and render blocks share the same coordinate system:

```

processed text offsets

```

That means:

- Every chunk knows which part of the processed text it covers
- Every render block also knows which part it covers

This shared reference is the bridge.

---

## 3. A Simple Mental Model

Imagine the book as one long line of text:

```

Processed Text Timeline
------------------------------------------------------------>
0        100        200        300        400        500

```

Now place **render blocks** on top:

```

[Block 0]--------|
[Block 1]--------|
[Block 2]--------|

```

And then place **embedding chunks**, which may overlap:

```

```
    [Chunk A]-----------------------|
                     [Chunk B]-----------------------|
```

```

A chunk may cover **multiple render blocks**.  
That is expected and intentional.

---

## 4. What Happens When a User Clicks an AI Quote?

When the AI shows a quote and the user clicks it, Mindory needs to answer one question:

> **Where should the reader be taken in the book?**

This happens in five clear steps.

---

## 5. Step-by-Step Positioning Logic

### Step 1: Find Render Blocks Covered by the Chunk

Each embedding chunk has a known text range:

```
chunk.range = [start_offset, end_offset)
````

So we can find all render blocks whose ranges overlap:

```pseudo
blocks = findRenderBlocksWhere(
    block.range overlaps chunk.range
)
````

Result:

```
[Block 12] [Block 13] [Block 14]
```

These blocks together represent the full reading context of the chunk.

---

### Step 2: Choose an Anchor Block

A chunk may span several blocks, so we need **one anchor**.

Mindory uses a simple and robust rule:

1. Try to find a block whose text contains the quoted snippet
2. If not found, fall back to the middle block

```pseudo
anchor = blocks.find(block contains quote)
if anchor is null:
    anchor = blocks[middle]
```

This avoids guessing and still feels natural to users.

---

### Step 3: Prepare the Dialog Content

For context, Mindory shows **all related blocks**, not just one:

```
Dialog Content:
[Block 12]
[Block 13]
[Block 14]
```

This gives users enough surrounding text to understand the quote.

---

### Step 4: Convert Block Index to Page Index

Render blocks are paged for reading.

If we show 10 blocks per page:

```pseudo
pageIndex = anchorBlock.index / 10
```

Example:

```
Block index: 137
Blocks per page: 10

Page index = 13
```

This maps a text position directly to a reading page.

---

### Step 5: Load and Display the Page

Finally, Mindory loads the page containing the anchor block:

```pseudo
start = pageIndex * pageSize
pageBlocks = loadBlocks(start, pageSize)
```

The dialog opens exactly where the quote belongs.

---

## 6. Why This Works

This design has several important advantages:

### No Guessing

* No sentence detection
* No fuzzy matching
* No language-specific tricks

Everything is based on positions.

---

### Stable and Testable

Same book + same chunk = same render blocks
Always.

This makes bugs easier to find and fix.

---

### User Trust

When users click a quote:

* The highlight matches the text
* The location feels correct
* The system feels honest

This is critical for a reading product.

---

## 7. One Diagram to Remember

```
Book Text (Processed)
---------------------------------------------------->

Render Blocks:
|----B0----|----B1----|----B2----|----B3----|

Embedding Chunks:
        |---------C7---------|
                   |---------C8---------|

User clicks quote from C7
            ↓
Find overlapping blocks: B1, B2
            ↓
Choose anchor: B2
            ↓
Jump to page containing B2
```

---

## 8. Final Takeaway

Mindory does not try to be clever here.

Instead, it relies on one strong idea:

> **If everything shares the same text coordinates,
> positioning becomes simple and reliable.**

Embedding chunks help the AI understand.
Render blocks help users read.

Offsets connect the two worlds.

And that connection is what makes AI assistance feel grounded, not magical.