# 扩展差分验证

在官方静态描述用例之外，新增固定种子的组合输入，对照未经修改的 ANTLR 4.13.2
Java 代码生成目标与运行时。期望结果由 Java 独立执行生成，不由 MoonBit 实现推导。

| 类别 | 对照数 | 检查内容 |
| --- | ---: | --- |
| Parser 组合输入 | 1008 | 左递归表达式、优先级、左右结合、可空分支、调用上下文、非贪婪路径；分别使用 SLL、LL、精确歧义模式 |
| Lexer 边界输入 | 84 | Unicode 标量位置、隐藏通道、注释、词法模式、more、未闭合字符串、非法字符及 EOF |
| 谓词与参数 | 126 | 真假配置、连续谓词、Token 后的谓词、规则参数、失败路径；同时比较谓词调用顺序 |
| 标号备选分支派发 | 8 | 通过 Java 生成的 Listener 接口代理记录实际通用回调、规则／备选分支回调及错误节点回调，比较完整次序 |

Parser 对照比较完整恢复树、Java `getText()` 上下文文本、诊断位置、剩余 Token，以及决策编号、起止位置、候选分支和
精确性等预测事件。Lexer 对照比较完整 Token 元数据与词法诊断位置。谓词对照另外比较
Java 宿主打印的调用轨迹。四类合计 1226 项，记录于 `tests/differential-manifest.json`。

## 已修复的差异

1. 左递归预测缺少上游的优先级过滤，导致额外报告歧义或上下文回退。实现
   `applyPrecedenceFilter` 对应逻辑：计算递归分支的有效优先级条件，移除已满足的条件，
   过滤具有等价返回上下文的退出分支，并保留外层优先级返回的抑制标记。
2. 预测到错误输入时，仅检查已完成路径的谓词，遗漏了上游对候选配置进行语义有效性
   分区的步骤。现在先检查配置的语义条件，再优先选择已完成的有效路径；无有效路径时
   才考虑已完成的无效路径，以保持错误定位和谓词观察顺序。
3. 补充 `RuleContext.get_text()`，提供 Java `ParseTree.getText()` 的拼接行为，包含 EOF
   和错误节点文本。原有 `text()` 保留排除 EOF 的接口约定。此行为同时加入所有固定
   上游 Parser 描述用例，覆盖关闭树构建及错误恢复。
4. 恢复节点在规则上下文中保留 `error_children` 标记，生成的 Listener／Visitor 可分别
   绑定 `error` 与 `terminal`。Listener 增加通用 `enter`／`exit` 回调，并默认采用 Java
   对标号备选分支的派发方式。旧的双重回调扩展通过 `antlr_dispatch=false` 显式启用。
   差分验证同时执行实际生成的 Listener 和 Visitor，覆盖恢复树的错误节点。

预测实现位于 `adaptive_prediction.mbt` 与 `prediction.mbt`，参考上游
`ParserATNSimulator.applyPrecedenceFilter`、`splitAccordingToSemanticValidity` 和
`getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule`，保留 BSD-3-Clause 来源声明。
上下文及遍历实现位于 `context.mbt`、`default_parser.mbt` 与原生目标生成器中。

## 复现

```sh
python tools/generate_target.py grammars/Differential.g4 --output generated/differential --jar /path/to/antlr-4.13.2-complete.jar
python tools/generate_target.py grammars/UnicodeModesLexer.g4 --output generated/unicode_modes_lexer --jar /path/to/antlr-4.13.2-complete.jar
python tools/generate_target.py grammars/SemanticDifferential.g4 --output generated/semantic_differential --jar /path/to/antlr-4.13.2-complete.jar
python tools/differential_oracle.py --jar /path/to/antlr-4.13.2-complete.jar
moon info
moon fmt
moon test --deny-warn
```

参考生成每次使用独立临时目录，验证 JAR 哈希，并固定随机种子与语法内容哈希。
CI 从原始语法重新生成并拒绝任何提交差异，再在四个编译目标运行测试。

这批输入扩大了已验证的兼容范围。它不是所有语法和输入的穷举，新增问题仍需通过
独立参考结果、最小复现和回归测试确认。
