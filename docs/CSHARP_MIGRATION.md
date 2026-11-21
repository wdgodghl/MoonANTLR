# C# 真实语法迁移案例与接入成本

## 案例版本与当前进度

采用 antlr/grammars-v4 的 csharp/v6 语法组，固定提交为 `7bb150f62f54e587f18e323b71fa0309bdec5056`。参考工具与运行时均使用官方 `antlr-4.13.2-complete.jar`，Java 基线使用 JDK 17。选择该案例是因为预处理返回属性、修改状态的动作和 Parser／Lexer 谓词会实际影响同一语言的解析结果。

原始三个语法文件已保存在 `grammars/csharp`，生成物位于 `generated/csharp` 和 `generated/csharp_preprocessor`。宿主实现位于 `csharp`，包括预处理属性与条件状态、插值状态机和四个 Parser 谓词。39 项原始语法输入和 19 项恢复 Java 对照已接入 `tools/csharp_oracle.py`，覆盖下表六项基线、嵌套分支、隐藏注释、插值格式和类声明。状态隔离和条件编译过滤另有应用测试。

以下记录保留迁移前的成本分析与六项 Java 基线。它们已有对应的 MoonBit 检查。原始语法文件未修改，33 个宿主辅助入口的行为在 MoonBit 中分组实现，三个内联谓词通过原始 Token 缓冲区索引实现。默认恢复入口已覆盖单 Token 插入／删除、调用上下文同步、错误节点和实际路径上的动作执行；预测器新增 SLL 外部返回路径及冲突终止分类。13 类、350 个上游静态功能描述用例已纳入独立对照；本案例和该有限语料的通过不能证明任意宿主程序。

固定版本来源

- [CSharpLexer.g4](https://github.com/antlr/grammars-v4/blob/7bb150f62f54e587f18e323b71fa0309bdec5056/csharp/v6/CSharpLexer.g4)
- [CSharpParser.g4](https://github.com/antlr/grammars-v4/blob/7bb150f62f54e587f18e323b71fa0309bdec5056/csharp/v6/CSharpParser.g4)
- [CSharpPreprocessorParser.g4](https://github.com/antlr/grammars-v4/blob/7bb150f62f54e587f18e323b71fa0309bdec5056/csharp/v6/CSharpPreprocessorParser.g4)
- [Java 辅助实现](https://github.com/antlr/grammars-v4/tree/7bb150f62f54e587f18e323b71fa0309bdec5056/csharp/v6/Java)
- [上游使用说明与 EPL-1.0 许可说明](https://github.com/antlr/grammars-v4/blob/7bb150f62f54e587f18e323b71fa0309bdec5056/csharp/v6/README.md)

## 人工改写清单与接入成本

该快照的三个语法文件共 2,432 个物理行，包含注释和空行。这是拟复用的语法规模，不代表已经迁移的有效代码量。逐文件核对得到以下工作清单。

| 文件或依赖 | 需要保留和人工迁移的内容 | MoonBit 处理方案及当前缺口 |
| --- | --- | --- |
| CSharpPreprocessorParser.g4 | 两个返回属性声明，分别为指令的 Boolean value 与表达式的 String value。通过子规则标签传递结果 | 将宿主类型映射为 Bool 和 String，为每次调用生成独立属性帧，动作写入本帧，父规则从标记的子规则读取返回值。已使用语义帧传递属性，并从原始声明生成 Bool／String 类型检查记录 |
| CSharpPreprocessorParserBase.java | 22 个语法调用的动作方法，另有条件汇总辅助逻辑。维护定义符号集合、条件栈及分支结果 | 人工将集合、栈和条件判断改写为 MoonBit，并绑定每个原动作位置。define／undef 对后续 if 的作用必须即时生效，不能使用整段成功后才执行的动作回放替代 |
| CSharpLexer.g4 与 CSharpLexerBase.java | 8 个动作辅助方法入口、2 个谓词辅助方法入口，涉及插值层级、逐层括号深度、普通／逐字字符串状态、模式切换与 skip | 人工改写这些状态和辅助方法，补齐自定义动作操作词法模式的接口，谓词读取当前扫描状态。Lexer 动作已能操作模式栈，配套插值状态已迁移 |
| CSharpParser.g4 与 CSharpParserBase.java | IsLocalVariableDeclaration 根据当前规则上下文与 local_variable_type 文本决定分支 | 将 Java 上下文访问转换为类型化 MoonBit 访问，为谓词提供真实调用上下文。仅有当前前瞻 Token 的回调不能表达这一条件 |
| CSharpParser.g4 | right_arrow、right_shift、right_shift_assignment 中的三个内联谓词检查标签 Token 的原始索引相邻关系 | 手动改写标签和索引访问，运行时保留包含隐藏通道 Token 的原始索引。不得只比较可见 Token 顺序，否则可能把带间隔的运算符误识别为复合运算符 |
| 三个语法的 options 与宿主继承 | tokenVocab、superClass 及相应基类方法绑定 | 保留词表及语法调用关系，将宿主基类替换为明确的 MoonBit 状态／回调接口，并给出生成与构造步骤 |

上述 33 个语法辅助方法入口由 8 个 Lexer 动作、2 个 Lexer 谓词、22 个预处理动作和 1 个 Parser 谓词组成，三个内联谓词另外登记。入口数量用于说明人工工作规模，不是工时承诺。预计主要接入成本集中在属性生命周期、即时动作、上下文和模式 API 的对应，随后是整份语法的编译及差异定位。

迁移时保留原语法的规则和备选分支、优先级、标签、Token 词表、模式与通道。为每处宿主类型和动作正文改写记录上游位置、原意、MoonBit 绑定名及对应测试。不得通过删去谓词、常量返回 true 或跳过状态动作获得“通过”。

## 已运行的真实 Java 基线

本次在固定快照上直接调用官方 4.13.2 Tool 生成三个 Java 解析器／词法器，配合上游三个 Java 基类编译后执行以下检查。这些输入现在均已在 MoonBit 端验证，完整 Token 与树对照由生成测试保存。

| 检查 | 输入或入口 | 本次 Java 参考结果 | MoonBit 验收需要观察的值 |
| --- | --- | --- | --- |
| 属性与状态动作 | 同一实例依次解析 define、if、else、endif，输入见下方 | 返回值依次为 true、true、false、true，零错误 | 逐条属性结果、符号集合变化、条件栈变化与实际调用顺序 |
| 相邻右移符号 | expression 入口输入 `8 >> 1`，检查消耗到 EOF | 接受，零错误 | 相同 Token 与表达式树 |
| 被空白隔开的右移符号 | expression 入口输入 `8 > > 1`，检查消耗到 EOF | 拒绝 | 原始 Token 索引和诊断位置，不能将两个符号合并通过 |
| 显式类型的多变量声明 | declarationStatement 入口输入 `int x=1,y=2;` | 接受，零错误 | local_variable_type 上下文及谓词结果 |
| var 的多变量声明 | declarationStatement 入口输入 `var x=1,y=2;` | 拒绝 | 同一上下文谓词应返回 false，不能使用统一常量回调 |
| 插值字符串 | 完整分词 `$"value={1+2}"` | 零词法错误，类型序列见下方 | Token 类型、文本、通道、位置及模式／状态变化 |

属性与状态动作的完整输入

```csharp
#define FEATURE
#if FEATURE && !false
#else
#endif
```

使用同一 CSharpPreprocessorParser 实例，CommonTokenStream 选择 CSharpLexer.DIRECTIVE 通道，反复调用 preprocessor_directive 至 EOF。上游基类默认定义 DEBUG，测试输入通过 define 再定义 FEATURE。预处理 Token 有单独通道，迁移时需要显式构建该通道的 Token 流。

插值字符串参考类型序列

```text
INTERPOLATED_REGULAR_STRING_START
REGULAR_STRING_INSIDE
INTEGER_LITERAL
PLUS
INTEGER_LITERAL
DOUBLE_QUOTE_INSIDE
EOF
```

## 迁移收益与仍需投入的工作

同一组语法同时承担词法分析、预处理及语法解析。迁移后可由 MoonBit 工具读取 C# 源码，计算条件编译分支并构建供代码浏览或静态分析使用的结构。复用价值来自保留这些规则之间的关系与既有语法结构，人工适配集中在上表中的宿主接口。

这项收益以完整案例通过为前提。当前版本已有原始语法的生成、编译、宿主运行和双端比较。后续仍需扩大 C# 输入覆盖，特别是非法预处理嵌套和插值边界，并完成与上游默认恢复一致的错误处理。

## 完整兼容验收边界

1. 参考环境固定为 ANTLR Tool 与 Java runtime 4.13.2。迁移后的 MoonBit 语法保留上述语法结构和判定条件，宿主代码采用等义 MoonBit 实现。所有人工改写逐项登记。
2. 先完成上表六项成对检查，保存可复现的 Java 与 MoonBit 输出。对照 Token 类型、文本、通道、原始索引和位置，属性值，选定分支，动作与谓词求值位置，以及树和诊断。仅目标语言类型拼写、库 API 拼写和诊断措辞可归一化。
3. 再加入 define／undef 后立即求值、嵌套 if／elif／else、多个解析实例隔离、普通与逐字插值、嵌套大括号、缺失结束符、注释隔开的复合运算符及连续错误用例。预处理状态、插值状态和动作异常后的终止行为都需检查。
4. 完整案例要求三个原语法覆盖的相关输入在四个编译目标通过，同时通过上游分类语法和运行时用例。保留失败、未迁移及未解释差异清单，清单清零后才认定 ANTLR 4.13.2 完整兼容。C# 案例通过本身只证明该案例的迁移成果。
5. 严格接口的动作回放仍保留原有语义。案例改用 `parse_default_tokens` 的实际路径执行，属性和上下文谓词即时可见，恢复树保留错误节点。39 项输入和 19 项恢复对照已覆盖三个 Token 索引谓词、缺分号／右括号及连续语句；另有 39 个逐动作快照，覆盖全部 8 个 Lexer 和 22 个预处理动作入口，比较偏移、模式、插值栈、条件栈、符号集与返回属性。恢复入口在词法错误后保留诊断并继续解析。

## Java 参考检查复现

准备 JDK 17 和官方 antlr-4.13.2-complete.jar。先在独立目录下载上述三个语法文件和三个 Java 基类，均使用前文固定提交。将下方驱动保存为 MigrationBaseline.java，再在该目录运行以下命令。Windows 的 classpath 分隔符使用分号。

```sh
java -jar antlr-4.13.2-complete.jar -encoding UTF-8 -Dlanguage=Java CSharpLexer.g4 CSharpParser.g4 CSharpPreprocessorParser.g4
javac -encoding UTF-8 -cp antlr-4.13.2-complete.jar *.java
java -cp ".:antlr-4.13.2-complete.jar" MigrationBaseline
```

完整基线驱动如下，断言失败时进程会报错退出。

```java
import org.antlr.v4.runtime.*;
import java.util.*;

public class MigrationBaseline {
    static int errors;
    static BaseErrorListener listener = new BaseErrorListener() {
        public void syntaxError(Recognizer<?,?> r, Object symbol, int line, int col,
                                String message, RecognitionException e) { errors++; }
    };
    static CSharpLexer lexer(String source) {
        CSharpLexer lexer = new CSharpLexer(CharStreams.fromString(source));
        lexer.removeErrorListeners();
        lexer.addErrorListener(listener);
        return lexer;
    }
    static void expression(String input, boolean accepted) {
        errors = 0;
        CSharpParser parser = new CSharpParser(new CommonTokenStream(lexer(input)));
        parser.removeErrorListeners();
        parser.addErrorListener(listener);
        parser.expression();
        boolean actual = errors == 0 && parser.getCurrentToken().getType() == Token.EOF;
        if (actual != accepted) throw new AssertionError(input + " accepted=" + actual);
        System.out.println("expression " + input + " accepted=" + actual);
    }
    static void declaration(String input, boolean accepted) {
        errors = 0;
        CSharpParser parser = new CSharpParser(new CommonTokenStream(lexer(input)));
        parser.removeErrorListeners();
        parser.addErrorListener(listener);
        parser.declarationStatement();
        boolean actual = errors == 0 && parser.getCurrentToken().getType() == Token.EOF;
        if (actual != accepted) throw new AssertionError(input + " accepted=" + actual);
        System.out.println("declaration " + input + " accepted=" + actual);
    }
    public static void main(String[] args) {
        errors = 0;
        String source = "#define FEATURE\n#if FEATURE && !false\n#else\n#endif\n";
        CSharpPreprocessorParser parser = new CSharpPreprocessorParser(
            new CommonTokenStream(lexer(source), CSharpLexer.DIRECTIVE));
        parser.removeErrorListeners();
        parser.addErrorListener(listener);
        List<Boolean> values = new ArrayList<>();
        while (parser.getCurrentToken().getType() != Token.EOF) {
            values.add(parser.preprocessor_directive().value);
        }
        if (errors != 0 || !values.equals(List.of(true, true, false, true))) {
            throw new AssertionError(values.toString());
        }
        System.out.println("preprocessor values=" + values);
        expression("8 >> 1", true);
        expression("8 > > 1", false);
        declaration("int x=1,y=2;", true);
        declaration("var x=1,y=2;", false);
        errors = 0;
        CSharpLexer lexer = lexer("$\"value={1+2}\"");
        CommonTokenStream stream = new CommonTokenStream(lexer);
        stream.fill();
        List<String> names = new ArrayList<>();
        for (Token token : stream.getTokens()) {
            names.add(token.getType() == Token.EOF ? "EOF" :
                      lexer.getVocabulary().getSymbolicName(token.getType()));
        }
        if (errors != 0 || !names.contains("REGULAR_STRING_INSIDE") ||
            !names.contains("DOUBLE_QUOTE_INSIDE")) throw new AssertionError(names.toString());
        System.out.println("interpolation tokens=" + names);
    }
}

```

## 来源与许可证处理

语法文件头和上游 README 标明 EPL-1.0。原始语法、派生语法及辅助实现分别保留原有版权和许可声明，按 EPL-1.0 要求分发相应部分，MoonANTLR 自身 BSD-3-Clause 组件另行标明。分发前逐文件核对来源与修改记录。
