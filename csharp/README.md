# C# grammar migration

This package ports the host logic for the original grammars-v4 C# grammar at
commit `7bb150f62f54e587f18e323b71fa0309bdec5056`. The three upstream grammar
files are preserved under `grammars/csharp`. Generated packages contain the
full lexer, parser and preprocessor grammar.

The helpers port the preprocessor return values and condition state, eight
Lexer action helpers, two Lexer predicate helpers, twenty-two preprocessor
action helpers, the local-variable contextual predicate and the three Token
adjacency predicates. Dispatch uses original rule names and generated action
source metadata. Parsing uses the semantic frame entry and retains the complete
original Token buffer for index-sensitive predicates. The preprocessor and
syntax parser use the committed semantic execution and default recovery entry.

Public entry points are `tokenize(source)`, `directives(source)`,
`preprocess(source)`, `parse(source, rule="compilation_unit")` and
`parse_recovering(source, rule="compilation_unit")`.
Preprocessing filters inactive tokens and keeps original positions. State is
fresh for each source. The original default DEBUG symbol is preserved.

Run `moon run examples/csharp` for a complete example. Regenerate the 37
Java input cases and 17 recovery comparisons with
`python tools/csharp_oracle.py --jar /path/to/antlr-4.13.2-complete.jar`.
They compare Token types, text, positions and channels, directive return values
and parser trees. Invalid predicate examples compare rejection.

This package and the derived grammar artifacts are under EPL-1.0, with the
license text in LICENSE. They derive from the grammar and Java helpers credited
to Christian Wulf, Ivan Kochurkin and Positive Technologies in the original
grammar headers. Core MoonANTLR code remains under BSD-3-Clause.

This is a tested migration of the fixed upstream grammar, with bounded execution.
It does not establish compatibility for every C# program or for all ANTLR
grammars. The runtime's full upstream prediction and recovery corpus
remains separate conformance work. Malformed preprocessor nesting and
malformed interpolation state may fail with RuntimeError rather than producing
the same diagnostic as the Java host.
