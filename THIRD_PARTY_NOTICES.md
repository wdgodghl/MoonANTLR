# Third-party notices

## ANTLR 4

Reference implementation: <https://github.com/antlr/antlr4/tree/4.13.2>

MoonANTLR follows ANTLR 4.13.2 serialized ATN version 4. Runtime data structures
and deserialization semantics reference ANTLR's runtime implementations.
Grammar analysis uses the unmodified upstream tool. Native-target fixtures use
MoonANTLR's plugin emitter; bridge fixtures use upstream `.interp` artifacts.
Precedence-loop handling references upstream `ParserInterpreter`; the target
reuses the Java output-model templates bundled in the official tool jar.
The default error strategy ports the insertion/deletion, context recovery
and error suppression logic of upstream `DefaultErrorStrategy.java`.
The SLL conflict termination condition follows upstream `PredictionMode`.
Prediction and MoonBit emitters are implemented in this project.
The upstream BSD-3-Clause license is reproduced in
[licenses/ANTLR-LICENSE.txt](licenses/ANTLR-LICENSE.txt).

ANTLR is a separate upstream project. MoonANTLR is an independent project and
does not imply upstream endorsement.

## grammars-v4 C# grammar and Java helpers

Pinned source:
https://github.com/antlr/grammars-v4/tree/7bb150f62f54e587f18e323b71fa0309bdec5056/csharp/v6

Original grammar headers credit Christian Wulf, Ivan Kochurkin and Positive
Technologies and specify EPL-1.0. Original grammars are preserved under
`grammars/csharp`. Java reference helpers are under `tools/reference/csharp`.
Derived MoonBit helper implementations are under `csharp`; derived generated
artifacts are under `generated/csharp` and `generated/csharp_preprocessor`.
Each of these directories includes the EPL-1.0 license text. The CSharpOracle
test driver is original MoonANTLR verification code.

The port maps host runtime methods to MoonBit state and semantic-frame bindings.
The tests and source mapping are documented in `docs/CSHARP_MIGRATION.md`.

## ANTLR runtime test descriptors

`conformance/upstream` contains the original static functional descriptors and
Java target template from ANTLR 4.13.2's `runtime-testsuite/resources`.
They retain the upstream BSD-3-Clause license in `conformance/upstream/LICENSE`.
`conformance/position_adjusting_test.mbt` adapts the descriptor's Java
PositionAdjustingLexer operations. Generated fixture packages under
`generated/upstream` derive from those descriptor grammars. Source paths,
reproduction and comparison boundaries are recorded in `conformance/README.md`.
`tools/Upstream*.java`, `tools/upstream_oracle.py` and the CSharpTraceOracle
test driver are MoonANTLR verification code; they do not replace the original
reference helper sources.
