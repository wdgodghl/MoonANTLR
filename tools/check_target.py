"""Exercise the public plugin CLI, flags, split grammars and output reproducibility."""
import argparse
import ast
import os
from pathlib import Path
import subprocess
import tempfile
from build_target import build, ROOT
from generate import read_interp


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--jar", required=True, type=Path)
    cli.add_argument("--java", default=os.environ.get("JAVA", "java"))
    cli.add_argument("--javac", default=os.environ.get("JAVAC", "javac"))
    args = cli.parse_args()
    plugin = build(args.jar, ROOT / ".local" / "moonbit-target.jar", args.javac)
    for grammar, lexer in [("Typed", None), ("ModesParser", "ModesLexer")]:
        for enabled in [False, True]:
            with tempfile.TemporaryDirectory(prefix="check-target-", dir=ROOT / ".local") as directory:
                directory = Path(directory)
                command = [args.java, "-Dfile.encoding=UTF-8", "-cp", str(plugin) + os.pathsep + str(args.jar.resolve()),
                           "org.antlr.v4.Tool", "-Dlanguage=MoonBit", "-encoding", "UTF-8", "-Xexact-output-dir",
                           "-lib", str(directory), "-o", str(directory),
                           "-listener" if enabled else "-no-listener", "-visitor" if enabled else "-no-visitor"]
                sources = ([lexer] if lexer else []) + [grammar]
                subprocess.run(command + [str(ROOT / "grammars" / (name + ".g4")) for name in sources], check=True)
                assert not list(directory.glob("*.java")), "Target must emit MoonBit recognizers"
                parser = grammar if lexer else grammar + "Parser"
                lex = lexer or grammar + "Lexer"
                for name, kind, interp in [(parser, "parser", grammar), (lex, "lexer", lex)]:
                    source = (directory / (name + ".mbt")).read_text(encoding="utf-8")
                    data = source.split(f"pub fn {kind}_data() -> Array[Int] {{ ", 1)[1].split(" }", 1)[0]
                    assert ast.literal_eval(data) == read_interp(directory / (interp + ".interp"))[0]
                for suffix in ["Listener.mbt", "Visitor.mbt"]:
                    assert (directory / (grammar + suffix)).exists() == enabled
                assert (directory / "moon.pkg").exists()
    print("MoonBitTarget: combined/split grammar, ATN equivalence, listener/visitor flags passed")


if __name__ == "__main__":
    main()
