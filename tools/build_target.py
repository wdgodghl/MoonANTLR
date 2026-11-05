"""Build the ANTLR MoonBitTarget plugin with JDK 17+ and the pinned tool jar."""
import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import zipfile
from generate import ANTLR_SHA256

ROOT = Path(__file__).resolve().parents[1]


def build(jar, output, javac):
    jar = Path(jar).resolve()
    if hashlib.sha256(jar.read_bytes()).hexdigest() != ANTLR_SHA256:
        raise ValueError("Expected the official ANTLR 4.13.2 complete jar")
    scratch = ROOT / ".local"
    scratch.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="target-", dir=scratch) as directory:
        sources = sorted((ROOT / "tools" / "codegen").rglob("*.java"))
        subprocess.run([javac, "--release", "17", "-encoding", "UTF-8", "-cp", str(jar),
                        "-d", directory] + list(map(str, sources)), check=True)
        output = Path(output)
        output.parent.mkdir(parents=True, exist_ok=True)
        # Fixed timestamps make the plugin artifact reproducible as well.
        with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for path in sorted(Path(directory).rglob("*.class")):
                info = zipfile.ZipInfo(path.relative_to(directory).as_posix(), (2026, 1, 1, 0, 0, 0))
                archive.writestr(info, path.read_bytes())
    return output.resolve()


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--jar", required=True, type=Path)
    cli.add_argument("--output", type=Path, default=ROOT / ".local" / "moonbit-target.jar")
    cli.add_argument("--javac", default=os.environ.get("JAVAC", "javac"))
    args = cli.parse_args()
    print(build(args.jar, args.output, args.javac))


if __name__ == "__main__":
    main()
