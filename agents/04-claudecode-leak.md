# Claude Code 源码泄露事件解析

## 引言

2026 年 3 月 31 日，AI 领域曝出一起引发广泛关注的安全事件——Anthropic 旗下编程工具 Claude Code 因一次极其低级的配置失误，导致完整源码在全网范围内泄露。这并非普通的代码泄露事件，而是涉及超过 51 万行 TypeScript 代码的 Source Map 文件外泄。

从技术角度来看，此次事故的成因却异常简单：用于辅助调试的 Source Map 文件被错误地发布到了公开环境中。

本文将从 Source Map 的技术原理出发，深入分析这一看似微不足道的配置问题，如何在实际工程中演变为一次影响深远的安全事故。

## 泄露事件的发现与传播

2026 年 3 月 31 日，安全研究员 Chaofan Shou 发现，Claude Code 的完整源代码通过一个 Source Map 文件被意外公开。

消息曝光后，相关代码在开发者社区迅速传播。短短一天内，原本基于 TypeScript 实现的 Claude Code 已被社区重构，并衍生出多个开源版本。目前已经出现 Python、Rust 等语言实现，更多语言版本也在持续开发中，例如 claw-code 项目（https://github.com/ultraworkers/claw-code）。

## Anthropic 的官方回应与处理

面对突如其来的代码泄露，Anthropic 反应相对迅速。公司发言人在官方声明中表示：

> “今天早些时候，一次 Claude Code 的发布意外包含了部分内部源代码。此次事件未涉及任何敏感的客户数据或凭证。这是由于人为错误导致的打包发布问题，而非安全漏洞。我们正在采取措施，防止类似事件再次发生。”

随后，Anthropic 向 GitHub 发起了 DMCA 下架请求。然而，为时已晚——代码已经被广泛 fork 和 clone，在社区中形成了事实上的“被动开源”。

## 泄露代码的规模

此次泄露的是 Claude Code 的完整代码：

| 指标       | 数值         |
| -------- | ---------- |
| 代码行数     | 512,000+ 行 |
| 源文件数量    | 1,906 个    |
| 编程语言     | TypeScript |

## Source Map 导致泄漏的原理

### Source Map 基本概念与工作机制

Source Map 是一种 JSON 格式的映射文件，用于描述生成代码与原始源代码之间的位置对应关系，其核心作用是在调试过程中让开发者能够查看和调试原始代码而非构建后的代码。

在 TypeScript 项目中，代码通常可能经历多个处理阶段，包括：

- 转译（Transpilation）: TypeScript → JavaScript
- 打包（Bundling）: 将多个模块合并为一个或多个文件（可选）
- 压缩（Minification）: 对代码进行压缩和混淆（通常仅在生产环境）

在构建流程中，如果各个阶段的工具均启用了 Source Map 并正确传递映射信息，那么最终生成的 Source Map 可以保留从原始源代码到最终输出代码的完整映射关系。

### Source Map 文件结构剖析

Source Map 文件采用标准的 JSON 格式，其基本结构包含以下关键字段：

```json
{
  "version": 3,
  "sources": ["../src/utils.ts", "../src/index.ts"],
  "sourcesContent": [
    "export function add(a: number, b: number): number {\n  return a + b;\n}",
    "import { add } from \"./utils\";\n\nconst server = Bun.serve({\n  port: 3000,\n  routes: {\n    \"/\": () => new Response('Bun! The sum of 2 and 3 is ' + add(2, 3)),\n  }\n});\n\nconsole.log(`Listening on ${server.url}`);"
  ],
  "mappings": ";AAAO,SAAS,GAAG,CAAC,GAAW,GAAmB;AAAA,EAChD,OAAO,IAAI;AAAA;;;ACCb,IAAM,SAAS,IAAI,MAAM;AAAA,EACvB,MAAM;AAAA,EACN,QAAQ;AAAA,IACN,KAAK,MAAM,IAAI,SAAS,gCAAgC,IAAI,GAAG,CAAC,CAAC;AAAA,EACnE;AACF,CAAC;AAED,QAAQ,IAAI,gBAAgB,OAAO,KAAK;",
  "debugId": "2FE61E0FD224BA6C64756E2164756E21",
  "names": []
}
```

- version：Source Map 版本号（目前固定为 3）​
- sources：原始源文件路径数组​
- sourcesContent：关键字段，存放源代码内容
- mappings：核心字段，记录源文件与生成文件间的映射关系，使用 VLQ (Variable Length Quantity) 编码压缩存储
- names：源代码中出现的标识符（变量名、函数名等）数组​

## 重写 Claude code 

开发者 Sigrid Jin 是 Claude Code 的资深用户，对该产品有着深刻理解。在短短数小时内，他用 Python 从零重写了整个工具，推出了新版本“claw-code”。然而，他并未就此止步，随后又使用性能更高的 Rust 编程语言对该项目进行了重新实现。

## Clean‑room rewrite

据说 Sigrid Jin 是通过一种叫做 clean‑room rewrite 的工程方法重写了 Claude code。 

Clean‑room Rewrite 是软件工程和法律领域中的一种实践方法，旨在在不直接接触原始源代码的前提下，重新实现软件功能，从而避免版权、专利及商业机密等法律和合规风险。该方法最初应用于软件版权纠纷和合规开发场景，目的是在保证功能一致性的同时，使新代码从法律上被视为独立创作。

Clean‑room rewrite 的核心原则是隔离与独立。整个过程通常分为两个团队：分析团队和实现团队。分析团队负责研究原始系统的功能行为和接口规范，但不接触原始源码的具体实现；实现团队则根据分析团队提供的规范和功能描述，从零开始实现新软件。这样可以确保新实现不包含原始代码的具体实现细节，从法律角度上规避直接复制的风险。在实践中，团队也可能使用人工方法或辅助工具（如 AI 编程助手）来提高开发效率，但Clean-room原则要求任何辅助工具生成的代码必须基于功能描述而非原始源代码。

Clean‑room rewrite 主要用于规避以下几类问题：

- 版权侵权风险：直接复制已有源码可能触犯版权法，导致法律诉讼。通过 Clean‑room rewrite，开发者从功能规范出发独立实现软件，新代码在法律上被认定为独立创作，从而规避版权纠纷
- 知识产权纠纷：某些软件包含专利算法或商业秘密，直接使用或改写可能涉及专利侵权。Clean‑room rewrite 通过隔离原始实现，仅参考功能行为，避免触及原始专利或专有实现
- 商业机密泄露：直接依赖或反向工程原始源码容易泄露公司内部算法或技术细节。Clean‑room rewrite 方法确保实现团队不接触原始源码，避免敏感信息的泄露
- 开源许可合规问题：将未经授权的源码发布为开源版本可能违反原始许可证条款。通过独立实现，开发者可以自由选择新代码的许可证，避免合规风险

Clean‑room rewrite 不仅在法律合规上有价值，也在实际工程中具有重要意义。例如在开源社区或软件泄露事件中，开发者可以在不直接复制泄露源码的情况下，根据功能说明和行为规范重新实现软件，从而合法、安全地提供相同功能的替代版本。在现代开发中，人工智能辅助编程工具可以加速 Clean‑room rewrite 过程，但必须保证生成的代码来源于功能描述而非原始泄露代码。

Sigrid Jin 的操作堪称惊艳，展现了非凡的技术能力与风险规避意识。

## 总结

我们可以更深入地思考 Claude Code 代码泄露的影响。长远来看，这件事利大于弊。AI 辅助工具本质上涉及两方面：一是模型能力，二是工程能力——也就是近来流行的概念 “Harness Engineering” (https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)。Claude Code 的源码泄露，无疑会推动开源与闭源 AI 编程工具的发展，加速整个行业的创新与普及，对社会和技术生态都是好事。

另一方面，如果放到企业视角考虑：在现代 AI 编程工具的加持下，如果你的公司拥有一个像 Sigrid Jin 这样能力卓越的员工，你会感到高兴，还是担心？在今天，你又是如何看待公司自身的代码资产与安全的呢？