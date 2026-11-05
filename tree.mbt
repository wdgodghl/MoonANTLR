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

///|
/// A stable JSON tree for tools that do not link MoonBit types directly.
pub fn ParseTree::to_json(self : ParseTree) -> Json {
  self.fold(token => Json::object(Map([("token", token.to_json())])), (
    name,
    children,
  ) => {
    Json::object(
      Map([("rule", Json::string(name)), ("children", Json::array(children))]),
    )
  })
}
