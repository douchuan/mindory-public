# AI 辅助开发体验

## 背景

我有一个用 Rust 实现的 JVM 项目。目标是做一个功能完善的 JVM，带 LLVM JIT 编译器和垃圾回收器，支持 JDK 9+。这不是一个产品级项目，而是我个人的学习项目——通过从零实现 JVM 来理解运行时系统的底层原理。

这个项目停滞了几年，最近重新开始开发。借助 AI 辅助编程工具，在短短几天内完成了原本卡了我好几年的核心模块：JIT 编译器和 Oop 对象模型。这篇博客记录了这个过程中的体验和思考。

## 为什么停滞

### 技术瓶颈

JVM 内部有两座大山：**垃圾回收（GC）** 和 **JIT 编译器**。这两块不是简单的工程问题——它们需要理解编译器后端（LLVM IR）、对象内存布局、根集扫描、mark-sweep 算法等一系列专业知识。

GC 需要精确追踪所有对象引用，扫描线程栈和静态字段，做标记-清除-整理。JIT 需要对接 LLVM 的 ExecutionEngine，把 200 多个 bytecode opcode 翻译成 LLVM IR，处理函数调用、控制流、类型系统映射。

对一个业余项目来说，这些知识门槛太高。没有现成的教程一步步教你用 Rust 写这些，C++ 的 JVM 实现（如 HotSpot）代码量又大，阅读成本高。最终的结果就是：知道方向，但不知道从哪里下手，项目就搁置了。

## AI 改变了什么

重新捡起这个项目时，AI 辅助编程工具已经成熟了不少。核心变化是：**我不再需要自己从零设计整个方案，而是可以把模糊的问题描述给 AI，由它生成可运行的代码，我再 review 和调整。**

这不是「AI 帮我写代码」，而是「AI 帮我省去了从零开始的启动成本」。

### JIT 编译器：从 0 到 ~155/202 个 opcode

JIT 编译器是我之前完全不知道如何下手的部分。LLVM 的 C++ API 文档虽然详细，但如何把它嵌入到一个运行中的解释器里，让 JIT 编译的代码能调用解释器的运行时函数，这个架构问题卡了我很久。

AI 给出的方案是 **runtime callout 模式**：

```rust
// JIT 函数签名：void fn(i8* locals, i8* stack)
// LLVM IR 生成后编译为机器码，直接调用
(jit_fn.fn_ptr)(jit_locals.as_mut_ptr(), jit_stack.as_mut_ptr());
```

具体实现路径：

1. **bytecode → LLVM IR 翻译**：扫描 bytecode 中的所有跳转目标，为每个目标创建一个 LLVM BasicBlock，然后逐条翻译 opcode。控制流用 `builder.build_br` 连接，条件分支用 `build_conditional_branch`。

2. **runtime callout**：对于复杂操作（字段访问、对象分配、方法调用），生成 LLVM `call` 指令调用 `extern "C"` 的 Rust 函数。这些函数可以访问 JVM 的运行时状态（常量池、堆、线程），不需要在 LLVM IR 层面处理。

3. **方法调用**：`invokevirtual` / `invokespecial` / `invokestatic` / `invokeinterface` 四种调用指令是最复杂的。JIT 编译的代码需要通过 TLS（线程局部存储）传递调用上下文，runtime 函数解析方法后进行 JIT 调用或解释器回退。

4. **剩余 opcode**：`tableswitch`、`lookupswitch`、long / float / double / reference 的返回值栈槽展开、所有类型的参数传递——这些是纯翻译工作，但量很大。AI 帮我批量生成了这些 opcode 的 IR 翻译代码。

最终结果是 ~155/202 个 opcode 支持 JIT 编译（约 77%），剩余的可以通过解释器回退路径执行。如果让我自己查 LLVM C API 文档、调试 IR 生成、调试类型系统映射，估计又要几个月。

### Oop 模型：Slot 间接引用

JVM 的 GC 模型和 Rust 的所有权系统有根本冲突。Rust 的 `&T` 引用不能跨越 GC 周期——GC 可能移动对象，导致悬垂引用。C++ 里用裸指针 `Oop*` 就完事了，编译器不管。

AI 帮我实现了一个 **slot-based 堆模型**：

```rust
// 对象不直接持有指针，而是持有 slot_id（u32 索引）
pub enum Oop {
    Int(i32), Long(i64), Float(f32), Double(f64),
    Ref(u32),  // 堆槽位索引，不是指针
}

// 访问对象时必须通过 Heap
oop::with_heap(|heap| {
    let desc = heap.get(slot_id);
    // ... 安全访问
});
```

这相当于在 Rust 中模拟了 C++ 裸指针的灵活性，但通过借用检查器保证了安全。GC 做 mark-sweep-compact 时只需要更新 Heap 内部的映射，所有 `Oop::Ref(u32)` 自动指向新地址。

零 unsafe 代码，这在 JVM 实现里是比较难得的。

### 其他快速推进的工作

除了 JIT 和 Oop 模型，AI 还帮我快速完成了大量工程细节：

- **Class Parser 重写**：把基于 nom 的解析器替换为 `std::io::Cursor + Read` 模式，代码可读性大幅提升
- **解释器模块化**：将单一巨型 `interp.rs`（几千行）拆分为按 opcode 分类的 15 个独立文件，每个文件 50-200 行
- **JDK 9+ JImage 支持**：支持从 `lib/modules` 文件加载 JDK 内部类
- **invokedynamic 支持**：实现了 `StringConcatFactory` 和 `LambdaMetafactory` 的 bootstrap 方法解析，JDK 9+ 字符串拼接和 lambda 表达式终于能跑
- **17 个 Java 集成测试全部通过**：算术、OOP、数组、异常、控制流、递归、枚举、泛型……

## 具体体验

### AI 不是替代品，是加速器

AI 写出来的代码不是我最终想要的样子，但它帮我跳过了最痛苦的「从零开始」阶段。举个例子：

JIT 编译器中 `invokevirtual` 的实现，AI 第一版生成的代码结构是对的——创建 runtime callout 函数，通过 TLS 传递上下文——但细节有问题：

- 栈槽偏移计算错误（long / double 占两个槽位没考虑）
- 方法签名解析不完整（只处理了 int 和 reference，漏了 boolean / short / char）
- 异常处理路径缺失（NPE 时没有设置 pending exception）

如果没有 AI，我需要先搞清楚 LLVM 的 calling convention、如何在 JIT 编译的代码中传递栈指针、如何通过 TLS 关联上下文……这个调研过程可能要几天。

**AI 节省的不是写代码的时间，是调研和架构设计的时间。**

### 需要有自己的判断力

AI 生成的代码有几个常见陷阱：

1. **过度抽象**：会给每个 opcode 创建 trait 和宏，但实际上每个 opcode 就是 5-10 行的简单操作，用 match 分派就够了
2. **边界条件遗漏**：数组越界检查放在堆锁内部导致死锁（这是我实际踩到的坑——`check_bounds` 调用 `meet_ex` 创建异常对象，异常对象分配又需要获取堆锁，重入非互斥锁就死锁了）
3. **假设不存在的 API**：有时会调用不存在的 LLVM 方法或 Rust 标准库函数

我的角色从「写代码的人」变成了「审查代码的人」——这其实更接近高级工程师在实际工作中的角色。知道什么代码是对的，比能写出对的代码更重要。

### 对业余项目的意义

一个人做系统级项目，最难的是知识储备。JVM 涉及编译器、运行时、操作系统、并发等多个领域，没有任何一个人能精通所有。

AI 弥补了这个缺口——它不需要替代你的思考，只需要帮你跨过那些「不知道从哪里开始」的门槛。

## 项目现状

截至最近，这个项目已经实现：

| 模块 | 状态 |
|------|------|
| Class Parser | nom → Cursor+Read 重写完成 |
| Oop 模型 | Slot-based，零 unsafe |
| 解释器 | 202/202 opcode，按文件拆分 |
| LLVM JIT | ~155/202 opcode，四种 invoke* 支持 |
| invokedynamic | StringConcatFactory + LambdaMetafactory |
| JDK 9+ | JImage 类加载支持 |
| 集成测试 | 17/17 Java 测试通过 |

还有未完成的部分：

- **GC**：slot-based 堆模型搭好了 free-list 分配器，mark-sweep 还在推进
- **类验证器**：结构性验证 + 字节码类型安全验证都只有骨架
- **invokedynamic 完整支持**：目前是特例化常见 bootstrap 方法，完整 CallSite 机制还需要工作

## 总结

AI 辅助编程对系统级项目的价值，不在于「让不会写代码的人写出代码」，而在于**让有经验的人不再被知识盲区卡住**。

我的 Rust 水平没有变高，但我能在几天内完成 JIT 编译器——不是我变厉害了，而是 AI 帮我补上了编译器后端和 LLVM IR 的知识缺口。我做的事情是：定义问题、审查代码、修正边界条件、跑测试。这和以前做系统架构设计的角色本质上没有区别，只是执行层面的负担轻了很多。

对一个停滞了几年的个人项目来说，这种负担的减轻是决定性的。如果不是 AI，这个项目大概率继续搁置。有了 AI，它重新跑起来了。

## 具体的统计数据

### AI 辅助工具

- AI 辅助工具: claude code
- 模型: qwen3.6-plus

### 代码统计

统计时间范围：2026-04-19 至 2026-04-22

```bash
git log --since="2026-04-19" --pretty=tformat: --numstat | awk '{ add += $1; del += $2; total += $1 + $2 } END { printf "修改文件数: %s\n新增行数: %s\n删除行 数: %s\n总行数: %s\n净行数: %s\n", NR, add, del, total, add - del }' && echo -n "提交次数: " && git log --since="2026-04-19" --oneline | wc -l
修改文件数: 295
新增行数: 19271
删除行数: 7107
总行数: 26378
净行数: 12164
提交次数: 20
```

### 功能统计

1. Class Parser 重写 (04-19)

- 将 nom 解析器替换为 std::io::Cursor + Read 模式
- 建立 class parser 测试基线

2. Oop 对象模型重写 (04-20)

- 从原始指针模型替换为 slot-based heap 分配 (Oop::Ref(u32))
- 零 unsafe 代码访问堆对象，通过 with_heap / with_heap_mut 访问

3. 解释器重构 (04-20)

- 将单一巨型 interp.rs 拆分为按 opcode 分类的独立文件

4. LLVM JIT 编译器 (04-21 ~ 04-22)

- 初始 JIT 支持（bytecode → LLVM IR 翻译）
- JIT 方法调用：invokevirtual / invokespecial / invokestatic / invokeinterface — 通过 runtime callout 实现
- 实现剩余约 40 个 opcode（tableswitch、lookupswitch、返回值扩展等）
- 参数类型扩展（copy_args_to_locals 支持全类型）
- JIT 编译安全性测试（Box::leak boundedness test）

5. JImage 支持 (04-21)

- 支持 JDK 9+ 的 lib/modules JImage 格式类加载

6. 工程化 (04-22)

- Cargo workspace 重构，子 crate 依赖统一管理
- 升级依赖版本
- Java 集成测试框架（17 个测试文件）