// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "wdgodghl/moonantlr"

import {
  "moonbitlang/x@0.5.7",
}

version = "0.2.0"

readme = "README.md"

repository = "https://github.com/wdgodghl/MoonANTLR"

license = "BSD-3-Clause AND EPL-1.0"

keywords = [ "antlr4", "parser", "lexer", "atn" ]

preferred_target = "wasm"

description = "MoonBit runtime and tooling for ANTLR4 grammars"
