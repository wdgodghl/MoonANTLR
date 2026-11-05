"""Generate MoonBit recognizers using ANTLR's standard -Dlanguage=MoonBit target."""
import argparse
import os
from pathlib import Path
import subprocess
from build_target import build, ROOT


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("grammar", type=Path)
    cli.add_argument("--lexer", type=Path)
    cli.add_argument("--output", required=True, type=Path)
    cli.add_argument("--jar", required=True, type=Path)
    cli.add_argument("--java", default=os.environ.get("JAVA", "java"))
    cli.add_argument("--javac", default=os.environ.get("JAVAC", "javac"))
    cli.add_argument("--no-listener", action="store_true")
    cli.add_argument("--no-visitor", action="store_true")
    args = cli.parse_args()
    plugin = build(args.jar, ROOT / ".local" / "moonbit-target.jar", args.javac)
    args.output.mkdir(parents=True, exist_ok=True)
    subprocess.run([args.java, "-Dfile.encoding=UTF-8", "-cp", str(plugin) + os.pathsep + str(args.jar.resolve()),
                    "org.antlr.v4.Tool", "-Dlanguage=MoonBit", "-encoding", "UTF-8",
                    "-no-listener" if args.no_listener else "-listener",
                    "-no-visitor" if args.no_visitor else "-visitor",
                    "-Xexact-output-dir", "-lib", str(args.output.resolve()), "-o", str(args.output.resolve())]
                   + ([str(args.lexer.resolve())] if args.lexer else []) + [str(args.grammar.resolve())], check=True)


if __name__ == "__main__":
    main()
