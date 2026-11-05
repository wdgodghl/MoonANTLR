///|
/// Bottom-up tree traversal. Callbacks may raise application-specific errors.
pub fn[A] ParseTree::fold(
  self : ParseTree,
  terminal : (Token) -> A raise?,
  rule : (String, Array[A]) -> A raise?,
) -> A raise? {
  match self {
    Terminal(token) => terminal(token)
    Rule(name, children) =>
      rule(name, children.map(child => child.fold(terminal, rule)))
  }
}
