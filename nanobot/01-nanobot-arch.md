# Nanobot 架构解析
## 整体定位
Nanobot 是一个超轻量级 LLM Agent 框架，核心目标是：用最少代码复现完整 OpenClaw 能力 (Tool / Memory / Skill / Loop)。

## 核心抽象模型
### Agent 本质模型
Nanobot 可以抽象为：
```
Agent = LLM + ContextBuilder + ToolLoop + Memory + Skills
```
进一步抽象为经典 Agent 模型：
```
Perception ￫ Reasoning ￫ Acting ￫ Reflection
```
对应 nanobot 各阶段组件如下：

| 阶段 | 对应组件 |
| --- | --- |
| Perception | InboundMessage + Session |
| Reasoning | LLM (chat_with_retry) |
| Acting | ToolRegistry.execute |
| Reflection | MemoryConsolidator |

### 核心执行循环(ReAct Loop)
Nanobot 的本质是一个 ReAct Tool Loop：
```
while not done:
    response = LLM(messages, tools)
    if response has tool_call:
        result = execute(tool)
        messages.append(result)
    else:
        return final_answer
```
**关键点**：
- LLM 决定是否调用工具
- Tool 结果回写上下文
- 多轮迭代直到完成

## 系统整体架构
### 模块分层
Nanobot 可拆分为 5 层：
```
Channel Layer      （Telegram / Slack 等）
        ↓
Message Bus        （解耦通信）
        ↓
Agent Core         （AgentLoop）
        ↓
Capability Layer   （Tools / Skills）
        ↓
Infrastructure     （LLM / Memory / MCP）
```

### 核心组件关系
```
User → Channel → MessageBus → AgentLoop
                                ↓
                ContextBuilder / Memory
                                ↓
                              LLM
                                ↓
                           ToolRegistry
                                ↓
                             Tools
```

### AgentLoop: 系统核心
#### 职责
AgentLoop 是系统的“调度器”，负责
- 接收消息
- 构建上下文
- 调用 LLM
- 执行工具
- 管理会话

#### 执行流程
1. 接收 InboundMessage
2. 获取 Session
3. Memory 整合(必要时)
4. 构建 Prompt
5. 进入 Tool Loop
6. 输出结果
7. 保存 Session

## Context 构建机制
### Prompt 组成
ContextBuilder 构建的 prompt 包含：
```
System Prompt
+ Memory (MEMORY.md)
+ Skills
+ History
+ Current Message
```
这是 Agent “智能”的来源。

### 设计特点
**优点**：
- 可控
- 可扩展
- 易调试

**缺点**：
- Token 成本高
- Prompt 复杂度高

## Tools 系统(执行层)
### 核心抽象
Tool = 原子能力(可执行)

**定义**：
```
name + description + parameters(JSON Schema) + execute()
```

### 执行流程
```
LLM ￫ tool_call ￫ ToolRegistry ￫ Tool.execute ￫ result ￫ LLM
```

### 设计特点
**优点**：
- 标准化(JSON Schema)
- 可扩展
- 强约束

## Skills 系统(能力层)
### 本质
Skill = Prompt + Workflow + Tool 使用说明
不是代码，而是：给 LLM 的“操作手册”

### 工作机制

1. 注入 system prompt(摘要)
2. LLM 发现 skill
3. read_file 读取详情
4. 学习使用方式
5. 调用 tool

### 优势与局限
**优点**：
- 无需改代码即可扩展能力
- 灵活

**缺点**：
- 强依赖 LLM 理解
- 不可控(非强约束)
- 增加 token 成本

## Memory 机制
### 结构
```
MEMORY.md  (长期记忆)
HISTORY.md (历史日志)
Session    (短期上下文)
```

### 工作流程
```
Session ￫ 超长 ￫ MemoryConsolidator ￫ MEMORY.md
```

### 设计取舍(Trade-off)
**优点**：
- 简单
- 可读
- 易调试

**缺点**：
- 无语义检索(无向量数据库)
- 不适合大规模

## Tool / Skill / MCP 分层
| 层级 | 组件 | 作用 |
| --- | --- | --- |
| 执行层 | Tool | 原子操作 |
| 能力层 | Skill | 任务封装 |
| 接入层 | MCP | 外部扩展 |

### 关键关系
```
Skill ￫ 引导 LLM ￫ 使用 Tool
MCP ￫ 提供 Tool
```

## 安全模型
Nanobot 的安全可以抽象为四层：
- 输入安全(参数校验)
- 执行安全(命令限制)
- 网络安全(SSRF 防护)
- 输出安全(截断)

## 典型执行案例
**示例**：查询 GitHub PR
```
用户:查看 PR 状态
1. LLM 看到 github skill
2. 调用 read_file
3. 学习 gh CLI
4. 调用 exec
5. 返回结果
6. LLM 总结输出
```
完整链路：Skill ￫ Tool ￫ Result ￫ Answer

## 总结

Nanobot 的核心思想：用最简单的方式，实现完整 Agent 闭环。

其本质是：ReAct + Tool + Prompt Engineering 的最小实现