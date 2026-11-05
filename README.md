# MoonANTLR

MoonBit runtime and tooling for ANTLR4 grammars.

MoonANTLR is building toward an ANTLR4 MoonBit code-generation target and a
reusable MoonBit runtime. The first milestone executes serialized ATNs produced
by ANTLR 4.13.2, with generated MoonBit grammar modules and reproducible examples.

This repository is under active development. Full ANTLR4 target compatibility,
adaptive prediction, precedence predicates and error recovery are planned work.

## Development

Requires MoonBit compiler 0.10.16 or newer. The development baseline is
moonc 0.10.18. Check, build and test with:

```sh
moon check
moon build
moon test
```

## License

BSD-3-Clause. See [LICENSE](LICENSE) and
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
