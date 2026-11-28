"""Reject compilers below the acceptance baseline before running CI."""
import re
import subprocess

report = subprocess.check_output(["moon", "version", "--all"], encoding="utf8")
match = re.search(r"moonc v(\d+)\.(\d+)\.(\d+)([^\s]*)", report)
if not match:
    raise SystemExit("Cannot determine moonc version")
version = tuple(map(int, match.group(1, 2, 3)))
suffix = match.group(4).split("+", 1)[0]
valid = version > (1, 0, 0) or version == (1, 0, 0) and (
    not suffix or re.fullmatch(r"-rc[1-9]\d*", suffix)
)
if not valid:
    raise SystemExit("moonc 1.0.0-rc1 or later is required")
print("Acceptance compiler:", match.group(0))
