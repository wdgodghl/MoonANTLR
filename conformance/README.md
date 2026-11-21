# ANTLR 4.13.2 upstream functional corpus

`upstream/` preserves the 350 static functional runtime descriptors in all 13
functional descriptor categories from
[ANTLR 4.13.2](https://github.com/antlr/antlr4/tree/4.13.2/runtime-testsuite/resources/org/antlr/v4/test/runtime/descriptors).
`Java.test.stg` is the matching upstream Java target template from
`runtime-testsuite/resources/org/antlr/v4/test/runtime/templates/Java.test.stg`.
The BSD-3-Clause license is retained in `upstream/LICENSE`. Performance
benchmarks and runtime-internal unit tests are outside this descriptor corpus.

| Category | Cases |
| --- | ---: |
| CompositeLexers | 2 |
| CompositeParsers | 15 |
| FullContextParsing | 15 |
| LeftRecursion | 98 |
| LexerErrors | 12 |
| LexerExec | 42 |
| Listeners | 7 |
| ParseTrees | 10 |
| ParserErrors | 34 |
| ParserExec | 50 |
| SemPredEvalLexer | 8 |
| SemPredEvalParser | 26 |
| Sets | 31 |

Reproduce with JDK 17, Python 3.10+ and the checksum-verified official JAR:

```sh
python tools/upstream_oracle.py --jar /path/to/antlr-4.13.2-complete.jar
moon info
moon fmt
moon test --deny-warn
```

The driver follows the upstream descriptor reader's whitespace rules, renders
the original Java templates and generates both targets from the same grammar.
Java actions are instrumented only in private reference artifacts to record
their ordinal and next-token offset. Native artifacts retain the original
action bodies as metadata. MoonBit adapters implement state-changing actions,
predicates, arguments and attributes; observation-only printing is replaced by
direct assertions. The position-adjusting Lexer adapter implements the
descriptor's seek and token-boundary operations.

Assertions compare all Token metadata, full error-node trees, diagnostic
positions, error Token intervals, the remaining Token, action order/offsets,
every declared attribute in every rule frame and observable Parser member
state. Generated Visitor/Listener behavior also has dedicated API tests.
JVM-specific debug-DFA text and Java reflection/type spelling are not compared
as text. The driver compares the resulting structure with tree construction
enabled, including the descriptor that originally disables tree building;
debug-print flags do not change the structural comparison. Original expected
stdout is preserved in the descriptors rather than asserted verbatim.
This is a functional descriptor migration, not a port of every Java
runtime API or proof for every possible grammar/host program.

`manifest.json` records every descriptor and its SHA-256 after LF normalization.
Generation errors are collected and cause a nonzero exit; cases are not silently
skipped. The CI reference job regenerates and rejects changes to committed
artifacts. The runtime matrix compiles and runs these tests on wasm, wasm-gc,
JavaScript and native. Development-only `--reuse` is never used by CI.
