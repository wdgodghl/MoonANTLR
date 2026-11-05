# Third-party notices

## ANTLR 4

Reference implementation: <https://github.com/antlr/antlr4/tree/4.13.2>

MoonANTLR follows ANTLR 4.13.2 serialized ATN version 4. Runtime data structures
and deserialization semantics reference ANTLR's runtime implementations.
Grammar analysis uses the unmodified upstream tool. Native-target fixtures use
MoonANTLR's plugin emitter; bridge fixtures use upstream `.interp` artifacts.
Precedence-loop handling references upstream `ParserInterpreter`; the target
reuses the Java output-model templates bundled in the official tool jar.
Prediction and MoonBit emitters are implemented in this project.
The upstream BSD-3-Clause license is reproduced in
[licenses/ANTLR-LICENSE.txt](licenses/ANTLR-LICENSE.txt).

ANTLR is a separate upstream project. MoonANTLR is an independent project and
does not imply upstream endorsement.
