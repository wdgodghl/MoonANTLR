"""Generate original C# grammar comparisons using the pinned ANTLR Java tool."""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
from generate import ANTLR_SHA256

ROOT = Path(__file__).resolve().parents[1]
CASES = [
    ("directives", "#define FEATURE\n#if FEATURE && !false\n#else\n#endif\n"),
    ("directives", "#define X\n#undef X\n#if X\n#else\n#endif\n"),
    ("directives", "#if false\n#if true\n#else\n#endif\n#else\n#endif\n"),
    ("directives", "#if false\n#elif DEBUG\n#else\n#endif\n"),
    ("directives", "#if (DEBUG && true) || false\n#endif\n"),
    ("directives", "#if DEBUG == true\n#endif\n"),
    ("directives", "#if DEBUG != false\n#endif\n"),
    ("directives", '#line 42 "sample.cs"\n#line default\n#line hidden\n'),
    ("directives", "#region title\n#endregion title\n"),
    ("directives", "#pragma warning disable\n#nullable enable\n"),
    ("directives", "#warning message\n#error message\n"),
    ("directives", "#if false\n#define X\n#endif\n#if X\n#endif\n"),
    ("directives", "#if DEBUG\n#elif false\n#else\n#endif\n"),
    ("expression", "8 >> 1"),
    ("expression", "8 > > 1"),
    ("expression", "8 >/*gap*/> 1"),
    ("declarationStatement", "int x=1,y=2;"),
    ("declarationStatement", "var x=1,y=2;"),
    ("declarationStatement", "var x=1;"),
    ("tokens", '$"value={1+2}"'),
    ("tokens", '$@"a""b{1}"'),
    ("tokens", '$"value={1:00}"'),
    ("tokens", '$"a{new object { }}b"'),
    ("tokens", '$"a{1}" $"b{2}"'),
    ("tokens", '$"line\\n={1}"'),
    ("tokens", '$"😀={1}"'),
    ("declarationStatement", "int 变量=1;"),
    ("compilation_unit", "class C { int x; void F() { return; } }"),
    ("compilation_unit", "using System; class C { int F(int x) { return x+1; } }"),
    ("compilation_unit", "class C { int x }"),
    ("compilation_unit", "class C { int x;"),
    ("compilation_unit", "class C { void F() { int x = ; int y=2; } }"),
    ("compilation_unit", "class C { void F() { return;; } }"),
    ("expression", "x => x+1"),
    ("expression", "x = > x+1"),
    ("expression", "x >>= 1"),
    ("expression", "x > >= 1"),
]


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--jar", required=True, type=Path)
    cli.add_argument("--java", default=os.environ.get("JAVA", "java"))
    cli.add_argument("--javac", default=os.environ.get("JAVAC", "javac"))
    args = cli.parse_args()
    jar = args.jar.resolve()
    if hashlib.sha256(jar.read_bytes()).hexdigest() != ANTLR_SHA256:
        cli.error("ANTLR jar checksum mismatch")
    scratch = ROOT / ".local"
    scratch.mkdir(exist_ok=True)
    output = ["// Generated original C# grammar Java comparisons.", ""]
    with tempfile.TemporaryDirectory(prefix="csharp-reference-", dir=scratch) as directory:
        directory = Path(directory)
        grammars = ["CSharpLexer", "CSharpParser", "CSharpPreprocessorParser"]
        subprocess.run([args.java, "-Dfile.encoding=UTF-8", "-jar", str(jar),
                        "-encoding", "UTF-8", "-Xexact-output-dir", "-o", str(directory),
                        "-lib", str(directory)] +
                       [str(ROOT / "grammars" / "csharp" / (name + ".g4")) for name in grammars], check=True)
        sources = sorted(directory.glob("*.java")) + sorted((ROOT / "tools/reference/csharp").glob("*.java"))
        subprocess.run([args.javac, "-encoding", "UTF-8", "-cp", str(jar), "-d", str(directory)] +
                       list(map(str, sources)), check=True)
        payload = "".join(rule + " " + base64.b64encode(source.encode()).decode() + "\n" for rule, source in CASES)
        result = subprocess.run([args.java, "-Dfile.encoding=UTF-8", "-cp",
                                 str(directory) + os.pathsep + str(jar), "CSharpOracle"],
                                input=payload, encoding="utf-8", check=True, capture_output=True)
        rows = [json.loads(line) for line in result.stdout.splitlines()]
        assert len(rows) == len(CASES)
        for index, ((rule, source), row) in enumerate(zip(CASES, rows)):
            output += ["///|", f'test "CSharp Java {index:03d} {rule}" {{']
            quoted = json.dumps(source, ensure_ascii=False)
            if not row["accepted"]:
                output += [f'  let rejected = try {{ let _ = @csharp.parse({quoted}, rule={json.dumps(rule)}); false }} catch {{ @runtime.SyntaxError(_, _, _) => true; _ => false }}',
                           "  assert_true(rejected)"]
            else:
                if rule == "directives":
                    output += [f"  @debug.assert_eq(@csharp.directives({quoted}), {json.dumps(row['values'])})"]
                elif rule != "tokens":
                    output += [f"  assert_eq(@csharp.parse({quoted}, rule={json.dumps(rule)}).context.to_tree().to_sexpr(), {json.dumps(row['tree'])})"]
                tuples = ", ".join("(" + ", ".join(json.dumps(v, ensure_ascii=False) for v in token) + ")" for token in row["tokens"])
                output += [f"  let tokens = @csharp.tokenize({quoted}).map(t => (t.kind, t.text, t.start, t.end, t.line, t.column, t.channel))",
                           f"  @debug.assert_eq(tokens, [{tuples}])"]
            output += ["}", ""]
            if rule not in {"directives", "tokens"}:
                positions = ", ".join(f"(Some({line}), Some({column}))" for line, column in row["errors"])
                output += ["///|", f'test "CSharp Java recovery {index:03d} {rule}" {{',
                           f"  let result = @csharp.parse_recovering({quoted}, rule={json.dumps(rule)})",
                           f"  assert_eq(result.tree.to_sexpr(), {json.dumps(row['tree'], ensure_ascii=False)})",
                           f"  @debug.assert_eq(result.diagnostics.map(d => (d.line, d.column)), [{positions}])", "}", ""]
    (ROOT / "csharp/oracle_test.mbt").write_text("\n".join(output), encoding="utf-8", newline="\n")
    (ROOT / "csharp/oracle-manifest.json").write_text(json.dumps({
        "source_commit": "7bb150f62f54e587f18e323b71fa0309bdec5056",
        "antlr": "4.13.2", "cases": len(rows), "accepted": sum(row["accepted"] for row in rows),
        "recovery_cases": sum(rule not in {"directives", "tokens"} for rule, _ in CASES),
    }, indent=2) + "\n", encoding="utf-8", newline="\n")
    print("CSharp Java cases:", len(rows))


if __name__ == "__main__":
    main()
