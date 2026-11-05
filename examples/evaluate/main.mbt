///|
fn main {
  println(@evaluator.evaluate("1 + 2 * (3 - 4)")) catch {
    error => println(@debug.to_string(error))
  }
}
