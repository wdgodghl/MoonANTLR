"""Exercise the public CLI as an external JSON consumer."""
import json
import argparse
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--target", default="wasm")
args = parser.parse_args()


def inspect(*arguments):
    result = subprocess.run(
        ["moon", "run", "cmd/inspect", "--target", args.target, "--", *arguments],
        cwd=root, capture_output=True, encoding="utf-8", check=True,
    )
    return json.loads(result.stdout)


cases = [("json", '{"x":"中文😀"}', True), ("json", '{"x" 1}', False),
         ("arithmetic", "1+2*3", True), ("arithmetic", "1+*3", False),
         ("modes", 'hello //comment\n"world"', True), ("unknown", "x", False)]
for grammar, source, expected in cases:
    report = inspect(grammar, source)
    assert report["ok"] is expected, (grammar, report)
    if expected:
        assert report["tree"]["rule"] == "document"
        assert report["tokens"][-1]["kind"] == -1
    elif grammar != "unknown":
        assert report["diagnostic"]["code"] == "syntax_error"

scratch = root / ".local"
scratch.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix="config-", dir=scratch) as directory:
    path = Path(directory) / "config with spaces.json"
    path.write_text('{"message":"中文😀"}', encoding="utf-8")
    report = inspect("json", "--file", str(path))
    assert report["ok"] and report["tree"]["rule"] == "document", report
    assert any(token["text"] == '"中文😀"' for token in report["tokens"]), report
    path.write_text('{"x":\n}', encoding="utf-8")
    report = inspect("json", "--file", str(path))
    assert not report["ok"] and report["diagnostic"]["code"] == "syntax_error", report
    assert (report["diagnostic"]["line"], report["diagnostic"]["column"]) == (2, 0), report
    missing = path.with_name("missing.json")
    report = inspect("json", "--file", str(missing))
    assert not report["ok"] and report["diagnostic"]["code"] == "file_error", report
    assert report["diagnostic"]["path"] == str(missing), report
    path.write_bytes(b'{"message":"\xff"}')
    report = inspect("json", "--file", str(path))
    assert not report["ok"] and report["diagnostic"]["code"] == "file_error", report
    assert "usage" in inspect("json", "--file")
print(f"CLI JSON consumer ({args.target}): {len(cases) + 5} cases passed")
