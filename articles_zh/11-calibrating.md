# RAG 校准: 让 LLM 引用精准且可高亮
在检索增强生成（RAG）系统中，通常要求大语言模型（LLM）返回**指向源文档的精确文本锚点**。

典型的字段格式如下：
```json
"content_anchor": "源 chunk 的连续字面子串"
```

该字段对以下功能至关重要：
- 精准高亮显示
- 上下文扩展
- 引用验证

但在实际场景中，**LLM 生成的锚点往往“有幻觉”，并非完全精确**。

本文将介绍一种**轻量级引擎端校准策略**，可安全、确定性地修复这类错误。

---

## 为何 `content_anchor` 在实际中容易失效？
常见的失效模式包括：
- 多余的尾随字符
- 部分改写（意译）
- 虚构的后缀内容
- 开头正确，结尾错误

这些失效并非语义错误，而是**字符串精度问题**。

通常:
> **`content_anchor` 的前缀通常是正确的，问题多出在后缀部分。**

---

## 校准设计原则
> **绝不凭空生成文本，仅验证或截断。**

引擎仅允许以下操作：
- 缩短锚点长度
- 拒绝无效锚点
- 严禁改写或扩展锚点内容

---

## 校准目标
确保 `content_anchor` 满足：
- 是源文本片段的字面子串
- 连续无断裂
- 可唯一匹配
- 长度足够，具备实际意义

---

## 核心算法
### 分步逻辑
1. 检查锚点是否已存在于源文本片段中
2. 若不存在，从**末尾**逐步截断
3. 保留在源文本中存在的**最长有效前缀**
4. 若剩余长度过短，则直接丢弃

---

## 伪代码实现
```pseudo
function calibrateContentAnchor(chunk_text, raw_anchor):
    if raw_anchor is null or empty:
        return null

    // 先检查原始锚点是否完全匹配（归一化后）
    if normalize(chunk_text).contains(normalize(raw_anchor)):
        return raw_anchor

    // 转换为字符数组，便于截断
    chars = raw_anchor.chars()

    // 从末尾逐步缩短，寻找最长有效前缀
    for i from chars.length downTo 1:
        candidate = chars[0..i] // 取前i个字符
        if normalize(chunk_text).contains(normalize(candidate)):
            // 验证长度是否达标
            if candidate.length >= MIN_ANCHOR_LEN:
                return candidate
            else:
                return null

    // 无有效前缀时返回 null
    return null
```

---

## 安全性保障
该算法确保：
- 无虚构文本生成
- 不从中段截取内容
- 无虚假匹配
- 结果完全可复现

若校准失败，将直接**丢弃该引用标注**，而非猜测填充。

---

## 实际效果
校准后可实现：
- 前端 `includes(anchor)` 校验稳定通过
- 锚点高亮功能可靠可用
- 上下文查询逻辑稳定
- 降级逻辑极少触发

最重要的是：
> **系统在不削弱提示词能力的前提下，重新获得了确定性。**

---

## 可观测性设计（可选但推荐）
为长期调试 LLM 行为，建议保留原始数据：
```json
{
  "content_anchor": "校准后的文本锚点",
  "raw_content_anchor": "LLM 原始输出",
  "anchor_repair": {
    "status": "truncated",
    "original_length": 18,
    "final_length": 11
  }
}
```

---

## 总结
LLM 擅长判断“引用什么内容”，但引擎必须负责确保“引用内容的准确位置”。

通过对 `content_anchor` 应用基于前缀的保守校准策略，可让 RAG 系统的引用具备：
- 精准性
- 可高亮性
- 生产环境可用性

> **精度 = LLM + 工程**