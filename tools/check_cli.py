"""Exercise the public CLI as an external JSON consumer."""
import json
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
cases = [("json", '{"x":"中文😀"}', True), ("json", '{"x" 1}', False),
         ("arithmetic", "1+2*3", True), ("arithmetic", "1+*3", False),
         ("modes", 'hello //comment\n"world"', True), ("unknown", "x", False)]
for grammar, source, expected in cases:
    result = subprocess.run(["moon", "run", "cmd/inspect", "--", grammar, source], cwd=root, capture_output=True, encoding="utf-8", check=True)
    report = json.loads(result.stdout)
    assert report["ok"] is expected, (grammar, report)
    if expected:
        assert report["tree"]["rule"] == "document"
        assert report["tokens"][-1]["kind"] == -1
    elif grammar != "unknown":
        assert report["diagnostic"]["code"] == "syntax_error"
print(f"CLI JSON consumer: {len(cases)} cases passed")
