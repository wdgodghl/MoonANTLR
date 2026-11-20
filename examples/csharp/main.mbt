///|
fn main {
  let source = "#define FEATURE\n#if FEATURE\nclass C { int F(int x) { return x+1; } }\n#else\ninvalid inactive source;\n#endif\n"
  let tree = @reader.parse(source) catch { _ => abort("C# example failed") }
  println(tree.context.to_tree().to_sexpr())
}
