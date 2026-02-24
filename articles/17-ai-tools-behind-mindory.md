# AI Tools Behind Mindory: A Practical Summary (With Performance Lessons)

Building Mindory was not a traditional solo engineering process. It was a collaboration between human judgment and multiple AI systems.

This article summarizes the AI tools involved in Mindory’s development, their strengths, limitations, and the engineering discipline required to turn AI-generated code into production-grade software.

The key takeaway:

> AI can generate structure fast.  
> But correctness, architecture, and performance still require human discipline.

---

# 1. ChatGPT

## Main Use Cases

ChatGPT played a strategic and product-level role during development.

It was primarily used for:

- Product definition
- Key decisions (pricing strategy, app UI style, website style)
- Prompt generation for other AI systems
- English/Chinese translation for in-app copy
- Business model validation
- System architecture discussion

In practice:

> ChatGPT functioned as a strategic co-founder rather than a simple coding assistant.

---

## Experience & Observations

- Overall performance met expectations.
- When conversations became long, the input box began lagging.
- Heavy context eventually required migrating to a new conversation.

Interestingly:

- During context migration, simple one-shot questions were intelligently excluded.
- The transition was relatively smooth.

### Limitation

Very long conversations can degrade UI responsiveness,  
requiring manual context reset and conversation management.

---

# 2. Manus

## Main Use Case

Manus was primarily used to generate the official website.

It performed well in:

- Generating the base website structure
- WYSIWYG design workflow
- UI layout and color matching
- Producing code aligned with Next.js design patterns

Strengths:

- Visually coherent layouts
- Clean component structure
- Good default aesthetic decisions

---

## Limitations

- CSS was generated using Tailwind.
- Although a `global.css` file was produced, it was not actually utilized.
- Many layout values were hardcoded as “magic numbers” directly inside TSX files.

This creates:

- Maintainability challenges
- Reduced flexibility for future theming
- Harder long-term scaling of design systems

Conclusion:

> Manus is strong in visual output but requires architectural cleanup before production.

---

# 3. Baidu Miaoda

## Main Use Case

Baidu Miaoda was used to generate the initial Mindory app framework.

The application is:

- Rust-based
- Built with Tauri

Miaoda provided:

- A working app skeleton
- WYSIWYG generation
- Strong mock functionality for rapid prototyping

---

## Observations on Mock Design

The mock capability is useful for early-stage validation.

However, improvements are needed:

- Adopt interface-oriented programming
- Explicitly label mock implementations
- Clearly mark components that must be replaced with real services

Without this clarity, teams risk:

- Shipping mock logic
- Overlooking temporary scaffolding

---

## Limitations

- No support for the Next.js stack
- Automatic inclusion of Baidu Cloud services
- Injection of Miaoda-specific plugins

This introduces:

- Vendor lock-in risk
- Architecture pollution
- Reduced portability

Conclusion:

> Strong for scaffolding, but requires careful decoupling before production use.

---

# 4. Large Model Used: Doubao

Model:

- doubao-seed-1-6-flash-250828

Observations:

- Strong reasoning quality
- Excellent performance-to-cost ratio
- Suitable for production-grade deployment

Compared to some alternatives:

- Long-context performance was more stable
- Input responsiveness remained smooth even with large context windows
- UI-related code generation was often cleaner

It proved to be highly practical for high-frequency inference scenarios.

---

# 5. Trae

## Strengths

- Free to use
- Helpful for quick code drafts

## Limitations

- Must be reviewed carefully
- May focus on incorrect context
- Can introduce unintended bugs
- Occasionally loses prior modifications

The core issue:

> Context misalignment.

AI sometimes locks onto outdated assumptions and generates logically inconsistent changes.

Every modification must be reviewed and regression tested.

---

# 6. Overall Development Experience

AI tools dramatically accelerated:

- Framework scaffolding
- UI generation
- Business modeling
- Copywriting
- Structural prototyping

They are extremely efficient for:

- Producing first working versions
- Exploring architectural alternatives
- Generating repetitive boilerplate

However:

> Generated code is not production-ready by default.

Acceleration does not equal optimization.

---

# 7. Critical Engineering Practices

AI-generated systems require strict engineering discipline.

---

## 7.1 Always Review Generated Code

Never blindly trust output.

Check for:

- Hardcoded constants
- Hidden dependencies
- Incorrect imports
- Over-fetching data
- Redundant abstractions
- Architecture shortcuts

AI optimizes for "working code", not "optimal code".

---

## 7.2 Performance Awareness Is Mandatory

AI-generated implementations are often:

- Functionally correct
- Mock-friendly
- Readable
- But not performance-optimized

This becomes critical in:

- Cross-language calls
- Database-heavy systems
- Aggregation logic
- High-frequency operations

---

## 7.3 Cross-Language Optimization (Tauri Example)

In a Tauri architecture:

- TypeScript calls Rust
- Rust queries the database
- Results return to the frontend

A typical early AI-generated implementation may:

- Query one record at a time
- Perform multiple round-trip calls
- Filter and aggregate in memory
- Cross the language boundary repeatedly

This works — but scales poorly.

### Better Approach

- Join related tables in a single SQL query
- Apply filters directly in the database
- Aggregate using SQL functions
- Return a structured result set in one call

Core principle:

> Minimize IPC boundaries.  
> Perform computation where the data lives.

---

## 7.4 Push Computation Into the Database

A common anti-pattern:

1. Query raw data
2. Load large dataset into memory
3. Filter and aggregate in application code

This increases:

- Memory usage
- CPU overhead
- Latency
- Bandwidth consumption

Instead:

- Use SQL `JOIN`
- Use `GROUP BY`
- Use `COUNT`, `SUM`, `AVG`
- Apply indexed `WHERE` filters
- Optimize queries

Databases are optimized for set-based operations.

Application memory is not.

Principle:

> Compute where computation is cheapest.

---

## 7.5 Mock Code Is Not Production Code

AI-generated scaffolding often:

- Uses simplified in-memory data
- Ignores indexing
- Skips query planning
- Avoids batching logic

Before production:

- Replace mock logic
- Add proper indexing
- Review query plans
- Benchmark critical paths

---

## 7.6 Testing Is Mandatory

Unit tests must cover:

- Core business logic
- Pricing calculations
- Analytics systems
- Edge cases

But correctness alone is insufficient.

For critical paths, also include:

- Performance benchmarks
- Load testing
- Query profiling

---

## 7.7 Regression Testing for Interaction Changes

AI can unintentionally:

- Remove prior logic
- Break event chains
- Reset state incorrectly
- Introduce subtle race conditions

Every interaction update must be regression tested.

Interactive AI applications are stateful systems.  
Small mistakes can cascade.

---

# 8. Final Reflection

AI tools are powerful accelerators.

They:

- Reduce time to first version
- Enable rapid iteration
- Lower boilerplate cost
- Assist strategic thinking

But they do not:

- Guarantee architectural integrity
- Optimize performance automatically
- Replace disciplined engineering

The correct mindset is:

> AI accelerates iteration.  
> Humans enforce correctness, scalability, and performance.

Mindory was not built *by* AI.

It was built *with* AI —  
under continuous architectural supervision.