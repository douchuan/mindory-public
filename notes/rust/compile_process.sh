#!/usr/bin/env bash
set -euo pipefail

# Rust 编译过程逐步展示
# 使用 nightly rustc 的不稳定选项（-Z）来观察每个中间阶段。
# 安装: rustup default nightly

SRC="main.rs"
OUT_DIR="output"

mkdir -p "$OUT_DIR"

# ---------- AST (Abstract Syntax Tree) ----------
# 源代码解析后生成的抽象语法树，保留了宏展开后的完整语法结构。
# 用途：验证宏展开结果、排查语法/解析歧义。
stage_ast() {
    echo "=> AST"
    rustc "$SRC" -Zunpretty=ast-tree > "$OUT_DIR/ast.txt" 2>&1
    cat "$OUT_DIR/ast.txt"
}

# ---------- HIR (High-level Intermediate Representation) ----------
# AST 经过去糖（desugaring）、模式匹配展开、生命周期推导等转换后
# 得到 HIR——更接近编译器内部视角的代码表示。
# 用途：查看编译器"理解"的代码长什么样，排查 trait 消解和生命周期推断。
stage_hir() {
    echo "=> HIR"
    rustc "$SRC" -Zunpretty=hir-tree > "$OUT_DIR/hir.txt" 2>&1
    cat "$OUT_DIR/hir.txt"
}

# ---------- MIR (Mid-level Intermediate Representation) ----------
# HIR 进一步降低为基于控制流图（CFG）的三地址码形式。
# 所有运行时语义（借用检查、数据流分析、优化）都在这一层完成。
# 用途：理解借用检查器为何拒绝代码、观察编译器做了哪些优化。
stage_mir() {
    echo "=> MIR"
    rustc "$SRC" -Zunpretty=mir > "$OUT_DIR/mir.txt" 2>&1
    cat "$OUT_DIR/mir.txt"
}

# ---------- LLVM IR ----------
# MIR 经由代码生成管线翻译为 LLVM IR，此后交由 LLVM 后端做目标无关
# 优化（内联、SROA、GVN 等）并最终生成机器码。
# 用途：对比不同优化级别（-O/-Copt-level=3）下 LLVM 做了哪些变换。
stage_llvm_ir() {
    echo "=> LLVM IR"
    rustc "$SRC" --emit=llvm-ir -o "$OUT_DIR/output.ll" 2>&1
    cat "$OUT_DIR/output.ll"
}

# ---------- Assembly ----------
# LLVM IR 经由目标后端生成目标平台的汇编代码。
# 用途：验证零成本抽象是否真正"零成本"、检查内联和寄存器分配效果。
stage_asm() {
    echo "=> Assembly"
    rustc "$SRC" --emit=asm -o "$OUT_DIR/output.s" 2>&1
    cat "$OUT_DIR/output.s"
}

case "${1:-all}" in
    ast)     stage_ast ;;
    hir)     stage_hir ;;
    mir)     stage_mir ;;
    llvm)    stage_llvm_ir ;;
    asm)     stage_asm ;;
    all)     stage_ast; stage_hir; stage_mir; stage_llvm_ir; stage_asm ;;
    *)
        echo "Usage: $0 {ast|hir|mir|llvm|asm|all}"
        exit 1
        ;;
esac
