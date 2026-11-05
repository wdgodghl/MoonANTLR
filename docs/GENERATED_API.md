# Generated API

`MoonBitTarget` is an ANTLR 4.13.2 plugin that emits MoonBit recognizers over
the MoonANTLR ATN runtime. Generation needs Python 3.10+, JDK 17+ and the
official complete ANTLR jar. Executing the generated MoonBit needs none of them.

```sh
python tools/generate_target.py grammars/Typed.g4 --output generated/typed --jar /path/to/antlr-4.13.2-complete.jar
moon fmt
moon run examples/typed
```

Expected output:

```text
result = 9
numbers: 1, 2, 3
```

The helper builds the plugin jar and invokes the standard ANTLR Tool entry.
It checks the upstream jar SHA-256. `--java` and `--javac` select executables;
`--lexer` supports separate lexer/parser grammars. `--no-listener` and
`--no-visitor` suppress the corresponding output. Use a fresh output directory
when changing flags; the tool does not delete older generated files.

The plugin can also be used directly:

```sh
python tools/build_target.py --jar /path/to/antlr-4.13.2-complete.jar
java -cp '.local/moonbit-target.jar:/path/to/antlr-4.13.2-complete.jar' org.antlr.v4.Tool -Dlanguage=MoonBit -visitor -Xexact-output-dir -o generated/typed grammars/Typed.g4
```

On Windows use `;` instead of `:` between classpath entries. The plugin reuses
ANTLR's Java output-model templates internally, but its own emitter writes
MoonBit source. It neither emits nor translates Java recognizer source.
The implementation is in `tools/codegen/org/antlr/v4/codegen/target/MoonBitTarget.java`.

## Recognizers and contexts

The combined `Typed` grammar emits `TypedLexer`, `TypedParser`, and a distinct
type for each parser rule. A separate parser grammar uses its own name as the
parser type. Constructors deserialize the ATNs; reuse recognizers for repeated
calls. `TypedLexer::tokenize(source)` returns every emitted channel plus EOF.

```moonbit
let parser = @grammar.TypedParser::new()
let document = parser.parse_document("x=1+2*3; y=4 note;")
let entries = document.label_entries()
let first_value = entries[0].label_value()[0]
let operator = first_value.label_op()[0].text
let right = first_value.label_right()[0]
```

Each `parse_<rule>` entry checks the complete input. It returns that rule's
context, and raises `RuntimeError` for invalid input. This differs from ANTLR
entry methods that may accept a prefix when the rule omits EOF.

- `get_<rule>()` returns typed direct child rules.
- `get_token_<NAME>()` returns direct tokens; literals use `literal_<type>`.
- `label_<name>()` returns only the elements captured by that grammar label.
  Captures use ATN source states, so missing optional elements cannot shift
  another label. Both single and list labels return arrays: absent is empty,
  a single capture has one element, and repeated captures retain source order.
- `alternative()` returns the `#Label` of the selected alternative, if present.
- `as_<Label>()` safely narrows to that labelled context. Its `as_rule()` method
  exposes the enclosing rule's typed accessors.
- `raw()` exposes `RuleContext` for generic tooling: `text()`, `span()`,
  `to_tree()`, `rules()` and `tokens()`. Spans count Unicode scalars and exclude
  EOF; an empty rule has no span. Treat context arrays as immutable.

## Visitor and Listener

`TypedVisitor[T]` is a bottom-up fold. Its `terminal` callback maps tokens to
values; every rule callback receives its typed context and child values.
`TypedVisitor::new(terminal=..., rule=...)` supplies defaults for all rules.
Copy the record to override `visit_expression`, for example. An optional
`visit_alt_Number: Some(callback)` handles a labelled alternative and takes
precedence over its rule callback. Unset alternatives fall back to that rule.
EOF is passed to the terminal callback too.

`TypedListener::new()` provides no-op callbacks. Override `enter_expression`,
`exit_expression`, `enter_alt_Number`, `exit_alt_Number`, and/or `terminal`,
then call `walk(context.raw())`. For each node the order is rule enter,
alternative enter, children from left to right, alternative exit, rule exit.
This includes both general and alternative callbacks, unlike ANTLR Java's
alternative-only dispatch for labelled rules.

Visitors and listeners are grammar-specific: only pass contexts produced by
the matching generated parser. The checked-in example and `tests/typed_test.mbt`
demonstrate evaluation and traversal without parsing tree strings.

## Compatibility

This is the first native target implementation. It supports action-free
grammars, typed direct-child access, element/list labels, alternative labels,
direct left recursion and generated traversal. Semantic predicates, custom
actions, rule arguments/return attributes, non-greedy lexer decisions and
error recovery are outside the supported contract. Full ANTLR target/runtime
conformance is still under development; see `ARCHITECTURE.md`.
