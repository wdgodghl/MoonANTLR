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
SLL starts with an empty external context. If multiple alternatives survive,
the predictor retries with the actual caller return chain. DFA states intern
configuration sets, and token-labelled edges cache subsequent lookahead steps.
Caches belong to one parse and cannot retain another input's tokens or trees.
`Grammar::parse_detailed` returns decision, full-context-fallback, DFA-state and
cache-hit counters alongside the concrete context.

This is a bounded implementation of adaptive prediction, not a port of the
complete ANTLR `ParserATNSimulator`. An exhausted outer prediction context is
conservative: an accepted alternative stays viable. At 64 lookahead tokens,
all surviving alternatives remain available to the memoized ATN executor.
There is no fixed lookahead rejection or guessed winner. If several complete
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

Semantic predicates, embedded parser actions, custom lexer actions, non-greedy
lexer decisions and lexer EOF remapping are rejected explicitly. The synthetic
ANTLR left-recursion bookkeeping action is the only parser action accepted.
The native target does not provide rule parameters/return attributes or error
recovery. Lexical/syntax failure rejects complete input, rather than accepting
a valid prefix.

The lexer has a 64-call fragment limit and parser execution a 128-rule nesting
limit. Each stage defaults to 1,000,000 worklist operations; parser prediction,
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

The generated public `.mbti` files describe the actual exported API. Full
upstream target/runtime conformance and Mooncakes publication remain future
milestones.
