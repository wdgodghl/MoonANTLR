# Architecture

## Current execution path

1. The pinned upstream ANTLR 4.13.2 tool analyzes a `.g4` grammar.
2. `tools/generate.py` reads its integer-form `.interp` ATNs and rule tables.
3. Generated MoonBit modules call the runtime's checked ATN deserializer.
4. The lexer traverses the lexer ATN and selects longest matches, breaking ties
   by grammar rule order. Fragment calls keep an explicit return stack.
5. The parser traverses rule transitions with rule/position memoization and
   returns a rule-labelled parse tree. Hidden-channel tokens are filtered.

The generation step uses Java and Python. Tokenization and parsing execute in
MoonBit without Java, Python, Node packages or upstream runtime bindings.

## Execution boundaries

The current parser is a bounded, action-free ATN interpreter. It is not the
ANTLR adaptive LL(*) algorithm and makes no general equivalence claim for
ambiguous grammars. If several complete parses exist, the first complete
result in grammar order is returned. Resource exhaustion is a typed error.

Semantic predicates, precedence predicates (including ANTLR's transformed
direct left recursion), embedded parser actions, custom lexer actions and
non-greedy lexer decisions fail explicitly. No error recovery is performed.
Lexical/syntax failure rejects the complete input rather than accepting a prefix.

The lexer has a 64-call fragment nesting limit; the parser has a 128-rule
nesting limit. Each stage defaults to 1,000,000 worklist operations. This is
an initial correctness baseline, not a DFA-cached production performance claim.

Source offsets and columns count Unicode scalar values. They are not UTF-8 byte
offsets or UTF-16 indices. Lines start at 1, columns at 0, and token ends are
exclusive. The included reference uses ANTLR Java `CharStreams.fromString`.

## Public packages

- `wdgodghl/moonantlr`: ATN decoder, lexer, parser, tokens, trees and typed errors.
- `wdgodghl/moonantlr/generated/json`: generated JSON grammar fixture.
- `wdgodghl/moonantlr/generated/arithmetic`: generated arithmetic grammar fixture.

Generated fixtures expose the serialized arrays so decoder validation can be
tested independently. The runtime graph is opaque outside the package.

## Compatibility roadmap

- A native ANTLR `MoonBitTarget` and StringTemplate code-generation templates.
- Prediction contexts, DFA caching and adaptive SLL/LL prediction.
- Precedence and semantic predicates, labelled alternatives and lexer decisions.
- Structured error recovery and generated Visitor/Listener APIs.
- Wider grammar-corpus testing and downstream library integration.

The `.interp` bridge is a development milestone toward that target. It is not
presented as a completed upstream ANTLR language target.
