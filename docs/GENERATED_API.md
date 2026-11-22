# Generated API

`RuleContext.get_text()` follows ANTLR `ParseTree.getText()`: it concatenates
visible children, including EOF and error-node text. Use a typed context's
`raw()` accessor to call it. `RuleContext.text()` is the convenience form that
excludes EOF. Both return empty text when no visible tree children were built.

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
`TypedVisitor::new(terminal=..., rule=..., error=...)` supplies defaults for all
rules. The optional `error` callback receives recovered error nodes; if omitted,
it uses `terminal` for backward compatibility.
Copy the record to override `visit_expression`, for example. An optional
`visit_alt_Number: Some(callback)` handles a labelled alternative and takes
precedence over its rule callback. Unset alternatives fall back to that rule.
EOF is passed to the terminal callback too.

`TypedListener::new()` provides no-op callbacks. Override `enter`, `exit`,
`enter_expression`, `exit_expression`, `enter_alt_Number`, `exit_alt_Number`,
`terminal` and/or `error`, then call `walk(context.raw())`. Generic `enter` runs
first; generic `exit` runs last. Children are visited left to right and error
nodes use `error` instead of `terminal`. The default dispatch follows ANTLR Java:
labelled rules invoke their alternative callbacks instead of base-rule callbacks.
`new(antlr_dispatch=false)` retains the extension that invokes both kinds.

Visitors and listeners are grammar-specific: only pass contexts produced by
the matching generated parser. The checked-in example and `tests/typed_test.mbt`
demonstrate evaluation and traversal without parsing tree strings.

## Compatibility

This is the first native target implementation. It supports action-free
grammars, typed direct-child access, element/list labels, alternative labels,
direct left recursion and generated traversal. Full upstream conformance is
still under development.

For grammars containing Parser predicates, generated parse methods accept
`predicate=(rule, index, lookahead) => Bool`. Use `true` to enable that path
and `false` to reject it. Bind pure MoonBit callbacks and rewrite any host
language code manually. Calls without a binding fail with `Unsupported`.
For Lexer predicates use `lexer_predicate=(rule, index, offset, source) => Bool`.
Generated Lexer methods and combined grammar Parser methods expose the binding
when their lexer ATN contains a predicate. Split Parser grammars can pass the
binding through `grammar().parse_context`. Offset counts Unicode scalars.
Context-dependent predicates are outside this contract.

Custom Lexer actions use `lexer_action=(event, source) => ...`. Generated Lexer
and combined Parser entries expose this parameter when the lexer contains an
action. The runtime calls it after selecting the winning token path, in source
action order. The event carries the rule and action indices, the token start and
end, and the original action offset. The callback can set `event.text`,
`event.channel` and `event.emission` (`Emit(kind)`, `Skip` or `More`).
Built-in lexer mode commands remain available in the grammar. Without a binding,
the runtime rejects an ATN with custom actions.

Lexer events now expose `mode` and `mode_stack`. Use `set_mode`,
`push_mode` and `pop_mode` for equivalent host actions. A selected action
with an invalid mode raises a RuntimeError. `Emit(-1)` emits EOF and stops the
token stream. The callback type can raise RuntimeError, including mode-stack
underflow from `pop_mode`.

`Grammar::parse_semantic(source, bindings)` supports rule-local values and
context-dependent predicates. Each `RuleFrame` has named JSON `values`,
flowing `shared` values, and completed child frames. `RuleSemantics` provides
entry initialization, call-argument mapping, actions, and predicates.
Actions return updated frames during traversal, so the following predicate sees
the update. Generated packages preserve rule attributes in
`attribute_declarations()` and call-site expressions in
`argument_expressions()`, where applicable.

These bindings implement the original host expressions in MoonBit. The runtime
uses isolated snapshots while exploring alternatives, so semantic hooks must
avoid external side effects and mutations of nested JSON containers. Observable
results are the accepted `ParseResult.frame`. This entry disables rule-result
memoization and structural DFA pruning because attributes can affect decisions.
Generated attribute records expose checked Int, Bool, String and Double fields
through `from_frame`. Other host types retain JSON representations and need
manual binding. Arguments and initializers remain manually implemented host
expressions. The entry does not implement ANTLR's complete predictive semantic
model.
See `tests/semantic_test.mbt` for the binding implementation used by Java
attribute comparisons, including an action followed by a contextual predicate.

For embedded Parser actions, generated methods accept
`parser_action=event => ...`. The generator attaches the ANTLR action source
states to the parser ATN and exposes their order through `parser_action_sites()`.
The callback receives the rule index, action ordinal, next visible Token and
rule context at the action site. It replays actions in execution order after a
successful parse, including nested rules and rewritten left recursion. Rejected
strict parses invoke no callbacks. Actions whose mutations affect later
predicates or rule attributes can use `parse_default` with semantic bindings.
Its callbacks run on the committed path, including recovered paths.

`Grammar::tokenize_recovering` returns tokens and lexical errors. On a failed
match it reports the token attempt's start and discards the failed prefix and
offending scalar, capped at EOF. Use `recover_lexer=true` to carry these lexical
diagnostics into `Grammar::parse_recovering`.

`Grammar::parse_recovering` returns `RecoveryResult` with a context, diagnostics
and a completion flag. Its `repairs` field identifies committed insertions,
deletions and synchronized spans, with original Token locations. Pass explicit
token kinds via `sync_tokens` and cap edits
via `max_repairs`. Inspect diagnostics even if a repaired parse reaches EOF.
The editor under `examples/editor` shows how to consume the result.
`RecoveryResult::tree_with_errors()` adds inserted, deleted and synchronized
Tokens as error nodes with original coordinates. This is a separate tree view;
the existing RuleContext and ParseTree representations retain their APIs.

For rule entry points that may leave input behind, call
`grammar.parse_prefix(source, start_rule=rule_index)`. The result exposes the
rule context at `parsed.context` and the first unconsumed visible Token at
`next_token`. An explicit `EOF` in the rule still has to match. A greedy loop
at the end of an entry rule commits its next iteration when the next Token
uniquely identifies the loop body. This reports a missing operand for `1+`
instead of returning `1` as an expression prefix. Generated typed entry points
still require complete input. Prefix parsing tokenizes the whole source, so a
lexical error after the prefix can still fail the call.


`Grammar::lexer_cursor(source)` creates a demand-driven Lexer. Each
`next_token()` executes only the winning actions needed for that Token,
retaining mode/MORE state. Repeated EOF requests do not replay actions.
`recover=true` accumulates lexical errors visible through `diagnostics()`.
`parse_prefix_lazy` buffers Tokens only as consumed or requested by prediction,
including the first unconsumed Token. The eager prefix entry remains available.

`Grammar::parse_default(source)` invokes one rule with default local recovery,
without imposing an implicit EOF. Its result contains the rule context, semantic
frame, prediction counters, first unconsumed Token, ordered diagnostics and an
error-node tree. `parser_action` runs at the action site, after any previous
Token consumption. `semantics` supplies rule arguments, locals, returns,
actions and contextual predicates. These committed action hooks may update
external state; predicates must remain side-effect-free. The older
`parse_semantic` entry explores snapshots and retains its purity requirement.

`parse_default_tokens(tokens, original_tokens=all_tokens)` uses a prepared
channel buffer, preserving physical Token indices for host predicates.
`RecoveryTree::to_sexpr` distinguishes `(error ...)` nodes, and
`error_tokens()` enumerates their exact metadata in traversal order. Synthetic
Tokens use upstream start=-1/end=0 metadata; ordinary source spans remain scalar
indices with exclusive ends. Compatibility applies to the tested cases; the
complete upstream semantic/prediction corpus is still being expanded.

`RecoveryListener::walk` visits rules, terminals and errors in ParseTreeWalker
order. `RecoveryVisitor[T]` reduces a recovered tree with separate ordinary
and error Token callbacks. The default recovery oracle compares Listener traces
as well as the complete tree and Token metadata.

## Lifecycle, recovery labels and contextual lookahead

`parser_action_sources()` includes rule lifecycle bodies after inline actions.
`rule_action_sites()` identifies `(rule, phase, ordinal)` for `init`, `after`
and `finally`; bind these with the same Parser action/semantic hooks. Named
rule actions are retained rather than executed as source-language code.

Each base rule context exposes `from_raw(node)`, returning `None` for a different
rule name. Label selectors preserve inserted set Tokens in parse order even
where Java's generated set recovery omits a tree error node.

`RuleSemantics.wrap` constructs a fresh left-recursive attribute frame; override
it to retain arguments and initialize declared return/local defaults. The previous
context is its first child. `LexerContextPredicate` and
`SemanticEvent.lookahead(one_based_offset)` support text, position and dynamic
lookahead-dependent host predicates. Prediction bindings must remain pure.

## Committed configuration and exception clauses

`parse_default` and `parse_default_tokens` accept `prediction_mode` (`SLL` or
`LL`, default `LL`) and `build_tree` (default `true`). SLL forbids contextual
LL fallback. Without tree construction, child traversal is empty while element
labels and source spans remain available through separate captures. Semantic
invocation frames retain attributes independently of visible tree children.

`rule_exception_sources()` retains rule indices, exception declarations and
handler bodies. Bind `RuleSemantics.handle_exception` to map source-language
exception types, return a handled frame or rethrow an unmatched exception.
Missing bindings are rejected. Unrecoverable recognition failures reach custom
handlers before default reporting; inline repairs retain normal recovery.

Initialization runs before the rule's protected body, matching generated Java.
Normal completion runs after then finally. Body, after or catch failures unwind
finally from inner to outer; a failing finally executes once and replaces the
prior exception. Pure snapshot parsing remains separate from committed host
exception handling.

`RecognitionError(kind, line, column, expected)` distinguishes
`InputMismatchException`, `NoViableAltException` and `FailedPredicateException`
for source-language catch dispatch. Actions and handlers receive committed
frames: writes before a thrown exception remain visible to catch/finally, and
Parser member state is shared by nested invocations. An exceptionally exited
child remains in the partial tree; its call-site element label remains unset.

Committed argument-expression bindings may raise `RuntimeError` and receive the
caller's live frame. Evaluation effects such as a post-increment occur before
the call; they remain visible when argument evaluation throws and finally runs.
