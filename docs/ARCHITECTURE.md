# Architecture

## Generation and execution

ANTLR 4.13.2 analyzes each `.g4` grammar. The native `MoonBitTarget` plugin
is discovered by the standard `org.antlr.v4.Tool -Dlanguage=MoonBit` entry.
It emits lexer/parser types, serialized ATNs, typed contexts and optional
Visitor/Listener records. The plugin uses upstream Java output-model templates
internally and its own MoonBit emitter; Java recognizer source is never emitted
or translated. `tools/generate.py` also retains a minimal `.interp` bridge for
runtime fixtures. Both paths feed the same checked MoonBit ATN deserializer.

The lexer selects longest matches with grammar-order tie breaking, explicit
fragment return stacks, channels, modes and built-in lexer actions. The parser
executes the parser ATN and checks complete input. Rule results are memoized by
rule, input position, precedence and interned caller context. Runtime execution
uses MoonBit alone, with no Java, Python or upstream runtime bindings.

## Prediction

At multi-edge decisions the predictor performs epsilon closure, internal rule
calls and precedence checks over ATN configurations. Return contexts are
interned nodes `(follow state, previous precedence, parent)`, sharing tails.
SLL starts with an empty external context and follows grammar call sites after
leaving the decision rule. Conflicting subsets terminate SLL when no ATN
state is associated with a single alternative. If multiple alternatives survive,
the predictor retries with the actual caller return chain. DFA states intern
configuration sets, and token-labelled edges cache subsequent lookahead steps.
Caches belong to one parse and cannot retain another input's tokens or trees.
`Grammar::parse_detailed` returns decision, full-context-fallback, DFA-state and
cache-hit counters alongside the concrete context.

This is a bounded implementation of adaptive prediction, not a port of the
complete ANTLR `ParserATNSimulator`. Completed entry-rule alternatives are retained for local failure fallback. Lookahead follows the DFA until the alternatives resolve, the input ends or
the work budget is exhausted. Surviving alternatives remain available to the
memoized executor. If several complete
parses remain, the first complete grammar-order result is chosen. This does
not claim exact ANTLR conflict resolution for every ambiguous grammar.
Rejected input is revisited without pruning under the same shared budget to
preserve furthest-failure expected-token diagnostics.

## Left recursion and contexts

ANTLR rewrites direct left recursion before target generation. The runtime
retains the precedence-rule flags, passes rule-transition precedence arguments,
and checks precedence predicates. Only the outer rewritten precedence loop
wraps the previous context as the left child. An ordinary EBNF loop inside that
rule does not. This preserves nesting, precedence, prefix/postfix operators,
ternary expressions and left/right associativity in the tested grammars.
Indirect or nullable recursive invocations are not a supported extension.

Concrete `RuleContext` nodes preserve direct children, each child's consuming
or invoking ATN state, and the rule's traversed states. Generated accessors map
ANTLR label definitions to those states; they do not infer labels by child
position or token text. Left-recursive left operands use a synthetic source
state `-1`. `ParseTree` remains available as a smaller generic representation.
See `GENERATED_API.md` for label and traversal semantics.

## Execution boundaries

Parser semantic predicates can be bound to pure MoonBit callbacks. The callback
receives the rule index, predicate index and current visible Token. Semantic bindings also expose the current context and attribute frame. Lexer predicates can bind a
separate pure callback receiving rule index, predicate index, current Unicode
scalar offset and source. A false result removes the current lexer path. With callbacks, the executor evaluates
predicates on the real token traversal and avoids structural DFA pruning. Results
are scoped to a single parse. Lexer non-greedy decisions use ordered NFA closure;
competing rules still use longest match with rule-order tie breaking.

The default parser entry is strict. The opt-in recovery entry tries single Token
insertion/deletion and caller-specified synchronization, returning diagnostics
and an available tree. Inserted Tokens have empty text and zero-width spans.
Unrecoverable input returns the furthest available root prefix, if any.
Recovery retries share a work budget. Lexical errors raise by default. The
opt-in Lexer recovery mode skips the failed token attempt and records its location.
Resource errors always raise.
Lexer actions execute only for the winning token path and can change emission.
Parser action sites are recorded during traversal and replayed once in selected
parse order. The semantic snapshot entry binds rule arguments, return values and local
attributes without external side effects. The committed `parse_default` entry
executes one selected path with immediate actions and contextual predicates,
local insertion/deletion, context FOLLOW synchronization and error suppression.
It returns an explicit error-node tree and preserves synthetic Token metadata.
Its Listener and Visitor distinguish error nodes from ordinary terminals.
`parse_default_tokens` accepts prepared channels and physical Token indices; the
C# migration uses it for both preprocessing and syntax.

`LexerCursor` produces tokens only on demand, retaining modes and MORE state.
`parse_prefix_lazy` and `parse_default` request Tokens through a parse-local
channel buffer. Prediction can request lookahead; unread source does not
execute Lexer actions or produce lexical diagnostics.

The former fixed fragment and parser nesting cutoffs have been removed.
Each stage defaults to 1,000,000 worklist operations; parser prediction,
execution and diagnostic retry share the parser budget. These limits are
resource safeguards, not a general linear-time performance claim.

Source offsets and columns count Unicode scalars, not UTF-8 bytes or UTF-16
units. Lines start at 1, columns at 0, and token ends are exclusive. Empty
contexts have no span. Hidden-channel tokens stay in the token buffer and are
excluded from parser contexts.

## Packages

- `wdgodghl/moonantlr`: ATN, prediction, parser, contexts, tokens and errors.
- `generated/typed`, `generated/decisions`: native-target fixture packages.
- Other `generated/*`: `.interp` fixtures for independent runtime validation.
- `evaluate`, `csv`, `inspect`: arithmetic, CSV and structured report consumers.
- `examples/typed`: typed labels, alternative Visitor and Listener consumer.

The generated public `.mbti` files describe the actual exported API. The migrated upstream functional corpus and its comparison boundaries are
documented in [conformance/README.md](../conformance/README.md).

## Lifecycle and attribute scopes

The emitter retains inline actions and `@init`, `@after` and `finally` sites.
Committed parsing runs init once at rule entry, after on successful completion,
and finally on normal, recovered or exceptional exit from the protected body.
Initialization precedes that body, matching Java. Committed frames share Parser
member state across calls and retain writes made before an exception. Unwinding
preserves partial rule trees without assigning a failed call's element label.
Snapshot parsing uses pure bindings
and replays only the accepted path. `RuleSemantics.wrap` creates the fresh
attribute scope for each left-recursive context; bindings initialize defaults
and preserve formal arguments explicitly. Hidden set-insertion captures retain
synthetic labels without adding a tree error node, matching generated Java.

`LexerContextPredicate` exposes matched text, token-start and current positions.
`SemanticEvent.lookahead` requests one-based visible lookahead on demand.

## Prediction and observations

The native emitter records actual adaptive decision sites separately from LL(1)
switch decisions. Committed parsing executes SLL closure sets with deferred
predicates, then retries conflicts in the real invocation context. Exact mode
continues until conflicting alternative subsets agree. Prediction callbacks
record decision index, source offsets, alternatives, exactness and resolution.
`report_prediction=true` also creates DiagnosticErrorListener-style messages.

`SemanticEvent.control` exposes live prediction mode, tree-building and Bail
settings to committed actions. Invocation start/stop Token metadata, rule stacks
and lazy expected-token queries support host observation adapters. Disabled-tree
labels remain independent of visible children, including after dynamic toggles.

Parser and opt-in Lexer DFA dumps serialize states and edges derived from actual
ATN closure sets. Predicate-dependent Lexer edges and start states are not cached.
Actions inside referenced Lexer rules are suppressed, matching Java. The pinned
host adapters reject unknown action bodies and compare original stdout rather
than returning strings taken from reference expectations.
