# MoonANTLR

[![CI](https://github.com/wdgodghl/MoonANTLR/actions/workflows/ci.yml/badge.svg)](https://github.com/wdgodghl/MoonANTLR/actions/workflows/ci.yml)

**MoonBit runtime and tooling for ANTLR4 grammars.**

MoonANTLR 面向 ANTLR4 的 MoonBit 代码生成目标与运行时：让 `.g4` 语法能够在 MoonBit 原生程序和 WebAssembly 中复用，为语言工具、配置处理和 DSL 提供解析基础。

当前是早期开发版本。已打通 ANTLR 4.13.2 序列化 ATN → MoonBit 语法模块 → 词法分析与解析树的执行链路，提供 JSON、算术、CSV、词法模式、左递归与决策预测语法的 Java 对照测试，以及可运行的算术求值、CSV 字段提取和 JSON 报告工具。运行时完全使用 MoonBit；Java 和 Python 仅用于生成语法数据和参考测试。

## 当前能力

- 检查并读取 ANTLR serialized ATN version 4 整数格式。
- 基于 ATN 的最长词法匹配、规则优先级、fragment 调用及跳过空白。
- 有界自适应预测：SLL 模拟、共享返回上下文、冲突后的全上下文回退与 DFA 缓存。
- 直接左递归、优先级谓词、左右结合性、完整输入检查与解析树输出。
- 原生 `-Dlanguage=MoonBit` 插件，生成 Lexer、Parser 和各规则的解析入口。
- 按语法生成类型化上下文、元素/列表标签与分支标签访问，以及 Visitor／Listener。
- Unicode 标量位置、带行列信息的错误以及可配置执行预算。
- 官方 ANTLR Java 目标对照用例，比较解析树与每个 Token 的类型、文本及位置；数量见 `tests/oracle-manifest.json`。
- 支持独立 lexer/parser 语法、词法模式切换、MORE、隐藏通道及 Token 类型重映射。
- 畸形 ATN、错误输入和不支持特性的回归测试。
- 带通道筛选和安全游标操作的 Token 流、可读错误诊断和通用树折叠接口。

预测和代码生成均为首版实现，尚未达到上游 ANTLR 完整兼容性。预测按共享工作预算逐 Token 前瞻；多解时取语法顺序中的第一个完整结果。支持 Parser 与 Lexer 谓词回调、Lexer 非贪婪量词，以及可选的 Token 修复与同步恢复。Lexer 和 Parser 动作可绑定回调，词法错误可选择恢复。依赖局部属性的谓词及需要在解析时即时生效的 Parser 动作仍待支持。详细边界见[架构说明](docs/ARCHITECTURE.md)。

## 安装与运行

Mooncakes 已发布 `wdgodghl/moonantlr`。在 MoonBit 项目中运行 `moon add wdgodghl/moonantlr` 添加依赖。

需要 MoonBit 编译器 **0.10.16 或更新版本**，当前开发基线为 **0.10.20**。也可从源码运行：

```sh
git clone https://github.com/wdgodghl/MoonANTLR.git
cd MoonANTLR
moon version --all
moon update
moon check --deny-warn
moon build --deny-warn
moon test --deny-warn
moon run cmd/main
```

示例依次解析 JSON 文档和 `1 + 2 * (3 - 4)`，输出带规则名称的 S-expression。克隆后即可运行，不需要 Java 或 Python，也不需要下载 ANTLR 工具。

下游使用场景：

```sh
moon run examples/evaluate
moon run examples/csv
moon run examples/typed
moon run cmd/inspect -- arithmetic '1+2*3'
moon run cmd/inspect -- json --file './config.json'
```

`cmd/inspect` 接受 `json`、`arithmetic`、`modes` 或 `csv`。可直接传源文本，或通过
`--file` 读取 UTF-8 文件。读取失败返回 `file_error`，语法错误包含行列位置。
业务解析失败时输出 `ok: false` 和诊断对象；进程退出码不用于表示该报告的业务状态。
CSV 示例保留空字段，支持引号内换行和双引号转义；空源没有记录，末尾换行不额外生成记录。

其他目标：

```sh
moon test --target wasm-gc --deny-warn
moon test --target js --deny-warn
moon test --target native --deny-warn
```

JS 目标需要 Node.js；native 目标需要对应平台的 C 工具链。

## 浏览器示例

在仓库根目录运行 `moon build examples/editor --target wasm-gc` 和
`python -m http.server 8000`，然后用支持 WebAssembly JS String Builtins 的浏览器打开
`http://localhost:8000/examples/editor/`。示例展示赋值 DSL 的解析树、AST 和行列诊断。
输入 `x=1; = = = ; y=2` 可观察错误后仍保留的语句。

## 库接口

[`cmd/main`](cmd/main) 展示了调用生成语法模块的方法：

```moonbit
let grammar = @json.grammar()
let tokens = grammar.tokenize("{\"ready\":true}")
let tree = grammar.parse("{\"ready\":true}")
println(tree.to_sexpr())
```

其中 `@json` 对应 `wdgodghl/moonantlr/generated/json`。基础运行时位于 `wdgodghl/moonantlr`，公开接口见 [pkg.generated.mbti](pkg.generated.mbti)。

## 生成语法模块

原生目标接受组合语法，或使用 `--lexer` 指定独立词法语法。准备 Python 3.10+、JDK 17+ 和官方 [antlr-4.13.2-complete.jar](https://www.antlr.org/download/antlr-4.13.2-complete.jar)：

```sh
python tools/generate_target.py grammars/Typed.g4 --output generated/typed --jar /path/to/antlr-4.13.2-complete.jar
moon fmt
moon run examples/typed
```

输出 `result = 9` 和 `numbers: 1, 2, 3`。工具校验 JAR 的 SHA-256，构建 MoonBitTarget 插件，并调用 ANTLR 标准入口。可通过 `--java`、`--javac` 指定工具路径，生成物不含本地绝对路径。直接使用插件、类型化 API 与回调示例见[生成接口说明](docs/GENERATED_API.md)。

原有 `tools/generate.py` 保留为轻量 `.interp` 桥接，用于运行时对照和畸形数据测试。

## 后续方向

继续扩大真实语法兼容性，完善与上游一致的冲突处理、语义谓词、词法决策和结构化错误恢复；逐步扩展规则参数、属性及代码生成接口。

## 文档与来源

- [生成的类型接口与遍历示例](docs/GENERATED_API.md)
- [架构与功能边界](docs/ARCHITECTURE.md)
- [ANTLR4 兼容矩阵与计划交付](docs/ANTLR_COMPATIBILITY.md)
- [ANTLR 4.13.2 完整兼容目标与验收](docs/ANTLR_CONFORMANCE.md)
- [验证与测试重现](docs/VERIFICATION.md)
- [ANTLR 4.13.2](https://github.com/antlr/antlr4/tree/4.13.2)
- [ANTLR 新语言目标开发指南](https://github.com/antlr/antlr4/blob/dev/doc/creating-a-language-target.md)

## 许可证

BSD-3-Clause。项目代码版权归 `wdgodghl`，上游代码与参考来源保留其原有版权。详见 [LICENSE](LICENSE) 和 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
