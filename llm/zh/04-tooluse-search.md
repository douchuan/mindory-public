# LangChain 搜索工具解析

做 LLM 开发、RAG 项目或 AI Agent，「联网搜索」几乎是必备能力。

目前 LLM 生态中常见的搜索 API 有 Tavily、Serper.dev、Brave Search、Perplexity API、Google CSE 等。不同工具在成本、数据结构、是否提供网页内容、以及与 LLM 的适配程度上差异较大。

本文将系统介绍主流 LLM 搜索工具，并重点对比 Serper.dev 与 Tavily 的定位和适用场景。

---

# 主流 LLM 搜索工具对比（LangChain 友好版）

下面是开发者常用的几类搜索工具的简化对比（价格和额度可能随套餐变化，仅作为大致参考）：

|工具|核心定位|LLM 友好度|核心特点|
|---|---|---|---|
|Tavily|AI 搜索 API|★★★★★|搜索 + 网页内容提取一体化|
|Serper.dev|SERP API（Google 结果结构化）|★★★★☆|返回结构化搜索结果|
|Brave Search API|独立搜索引擎 API|★★★☆☆|独立索引、隐私优先|
|Perplexity API|生成式搜索|★★★★☆|返回答案 + 引用来源|
|Google CSE|Google Custom Search API|★★★☆☆|官方 API，支持自定义搜索|

LLM 友好度主要取决于：

- 是否返回结构化 JSON  
- 是否提供网页正文  
- 是否需要额外爬虫和清洗流程  

---

# 重点解析：Serper.dev vs Tavily

这两款工具在 LLM 开发中最常被对比，但它们的定位其实不同：

- Serper：SERP 数据 API
- Tavily：搜索 + 内容提取 API

可以理解为：

```

Serper → 搜索结果接口
Tavily → 搜索 + 内容抓取 + 内容提取

````

下面从几个维度说明。

---

# Serper.dev：SERP 数据 API（结构化搜索结果）

Serper.dev 提供的是 搜索引擎结果页（SERP）的结构化 API。

开发者发送查询后，API 会返回类似搜索引擎结果页中的数据，例如：

- 标题
- URL
- snippet（摘要）
- 排名信息
- 相关问题等

需要注意的是：

* Serper 返回的是结构化搜索结果数据
* 并不包含网页完整正文
* 若需要网页内容，需要开发者自行抓取 URL 并进行清洗

特点总结：

优势

* 成本较低
* JSON 结构清晰
* 可获得主流搜索结果数据

限制

* 不提供网页正文
* 需要额外的网页抓取和文本提取流程

适合：

* 大规模搜索调用
* 仅需要摘要信息
* 团队具备爬虫能力

---

# Tavily：面向 LLM 的搜索与内容提取 API

Tavily 的设计目标是减少 LLM 开发中的工程复杂度。

它不仅提供搜索结果，还会尝试：

* 抓取网页
* 提取主要内容
* 去除部分 HTML 噪声
* 返回结构化文本

典型返回数据包含：

* title
* url
* snippet
* extracted content（提取的正文）

因此开发者可以直接获得网页主要内容文本，减少额外爬虫步骤。

需要注意：

* 返回内容是提取的主要文本
* 并不一定是完整网页原文
* 具体内容长度可能受到 API 参数和限制影响

特点总结：

优势

* 搜索 + 内容提取一体化
* 减少爬虫和 HTML 清洗工作
* 对 LLM / RAG 更友好

限制

* 成本通常高于单纯 SERP API
* 可控性低于自建抓取 pipeline

适合：

* RAG 系统
* 研究型 Agent
* 快速原型开发
* 不希望维护爬虫系统

---

# 选型策略

选择搜索工具时，可以从三个维度考虑：

* 是否需要网页正文
* 预算
* 是否愿意维护爬虫

---

## 优先选择 Serper.dev 的情况

适合：

* 需要大量搜索请求
* 预算敏感
* 只需要搜索摘要
* 或团队可以自己抓取网页

常见场景：

* 搜索增强问答
* URL 发现
* 关键词检索

---

## 优先选择 Tavily 的情况

适合：

* 需要网页正文内容
* 希望减少工程复杂度
* 构建 RAG 或研究型 Agent

常见场景：

* 文档总结
* 研究型 AI Agent
* 知识库构建

---

## 其他工具适用场景

Brave Search API

适合：

* 需要独立搜索引擎
* 不依赖 Google 生态

---

Perplexity API

适合：

* 直接获取生成式答案
* 返回答案并附带引用来源

注意：

它本质上是 LLM + search 的服务。

---

Google CSE

适合：

* 企业系统
* 需要 Google 官方 API

需要注意：

CSE 是 Custom Search Engine API，通常用于自定义搜索范围。

---

# 总结

选择 LLM 搜索工具时，可以按照以下顺序判断：

是否需要网页内容

- 需要网页内容: 选择 Tavily
- 只需要搜索结果: 选择 Serper / Brave / Google CSE

是否愿意维护爬虫

- Y: Serper + 自建抓取 pipeline
- N: Tavily


是否追求最低成本

- 大规模调用: Serper
- 快速开发: Tavily

---

在实际生产系统中，很多团队会采用组合架构：

```
Serper / Search API
↓
爬虫抓取网页
↓
文本清洗
↓
RAG / LLM
```

而 Tavily 则提供了一种更集成的一体化方案，用更高的 API 调用成本换取更低的工程复杂度。
