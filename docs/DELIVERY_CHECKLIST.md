# 申报功能验收清单

本清单对应申报书的具体功能及验收条件。嵌入的 Java/C# 正文按申报方案迁移为
MoonBit 绑定，不宣称自动翻译任意宿主程序。

| 申报内容 | 实现与验证入口 |
| --- | --- |
| JSON 结构及带行列错误 | `generated/json`、`inspect/report.mbt`、`tests/oracle_test.mbt`；运行 `moon run cmd/main` |
| Visitor 按优先级求值 | `generated/typed`、`examples/typed`、`tests/typed_test.mbt`；运行 `moon run examples/typed` |
| 含引号、换行的 CSV | `csv/read.mbt`、`generated/csv`、`csv/read_test.mbt`；运行 `moon run examples/csv` |
| DSL 到 AST | `examples/editor/editor.mbt` 的 `expression_ast`、`analyze` 与编辑器应用测试 |
| WebAssembly 编辑器及错误后继续 | `examples/editor` 展示树、AST、行列诊断及恢复语句；CI 执行 `tools/check_editor.mjs` |
| 固定 C# 6 宿主迁移 | 固定来源的原始语法与 Java 基类；`csharp` 实现 33 个辅助入口与 3 个内联 Token 索引谓词，逐项映射见 `CSHARP_MIGRATION.md` |
| C# 条件编译、属性、插值及隔离 | 39 个 Java 输入对照、19 个恢复对照、39 个辅助方法快照；全部 8 个 Lexer 动作、22 个预处理动作，以及实例隔离应用测试 |
| 原生代码生成目标 | `tools/codegen` 与 `generate_target.py`；`check_target.py` 验证实际 CLI、组合/拆分语法、ATN 等价与 Listener/Visitor 开关 |
| 规则参数、返回值、局部属性 | 属性元数据、类型化记录、`RuleFrame`、`RuleSemantics`；独立调用及左递归作用域的 Java 逐层快照 |
| 即时动作及上下文谓词 | `parse_default` 实际路径执行；动态 `lookahead`；源码解析入口转发 `LexerContextPredicate` |
| SLL/LL 冲突选择 | `prediction_mode=SLL` 禁止 LL 回退；默认 LL 支持上下文回退；原始模式标志在两端实际应用 |
| 默认恢复及错误节点 | 插入、删除、上下文同步、连续错误；比较完整错误树、Token 区间、行列、剩余 Token 及动作偏移 |
| 关闭解析树构建 | `build_tree=false` 不产生子树与错误节点；独立保留标签及源区间；两端实际应用 `notBuildParseTree` |
| 生命周期及异常 | 保留 init、after、finally、catch 源码；34 个独立 Java 对照检查初始化失败、动作失败、处理器失败、嵌套退出、异常替换与恢复树 |
| 上游分类及四目标 | 13 类 350 个固定描述用例；CI 分别检查、构建、测试 wasm、wasm-gc、JS、native；参考任务从原始语法重新生成并拒绝差异 |
| 来源与许可证 | `THIRD_PARTY_NOTICES.md`、BSD-3-Clause/EPL-1.0 许可及语法声明；C# 派生部分保留 EPL-1.0 |

## 原始配置与比较边界

`conformance/manifest.json` 逐例记录原始标志、树构建设置和预测模式。未知标志导致生成失败。
SLL、LL 与关闭树构建均设置两端运行时，不能用默认配置的成功代替验收。

`showDFA`、`showDiagnosticErrors` 是上游调试展示标志，保留在清单中；结构化对照比较
Token、分支与树、诊断位置、动作偏移、属性与遍历事件。原始描述文件及 stdout/诊断文本
保留；JVM 调试文本不是 MoonBit 的输出接口。此语料不包含性能基准或所有 Java runtime
内部单元测试，也不构成对任意未知语法和宿主代码的形式化等价证明。

复现命令及固定工具版本见 `VERIFICATION.md` 和 CI。生成工具验证官方 JAR 哈希；用例
排序跨平台一致；临时参考产物不进入仓库。
