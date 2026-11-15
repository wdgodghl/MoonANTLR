import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const artifact = await readFile(new URL(
  "../_build/wasm-gc/debug/build/examples/editor/editor.wasm",
  import.meta.url,
));
const { instance } = await WebAssembly.instantiate(artifact, {}, {
  builtins: ["js-string"],
  importedStringConstants: "_",
});
const analyze = (source) => JSON.parse(instance.exports.analyze(source));

const valid = analyze("x=(1+2)*3; y=2^3");
assert.equal(valid.complete, true);
assert.deepEqual(valid.diagnostics, []);
assert.equal(valid.ast[0].value.op, "*");
assert.equal(valid.ast[0].value.left.op, "+");

const repaired = analyze("x=1; = = = ; y=2");
assert.equal(repaired.complete, true);
assert.equal(repaired.diagnostics[0].column, 5);
const entries = repaired.tree.children.filter((child) => child.rule === "entry");
assert.equal(entries.length, 2);
assert.equal(entries[1].children[0].token.text, "y");
