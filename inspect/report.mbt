///|
/// Inspect a complete source document. Failures are data with ok=false.
pub fn analyze(grammar : @runtime.Grammar, source : String) -> Json {
  try {
    let tokens = grammar.tokenize(source)
    let tree = grammar.parse(source)
    Json::object(
      Map([
        ("ok", Json::boolean(true)),
        ("tree", tree.to_json()),
        ("tokens", Json::array(tokens.map(token => token.to_json()))),
      ]),
    )
  } catch {
    error =>
      Json::object(
        Map([
          ("ok", Json::boolean(false)),
          ("diagnostic", error.diagnostic(grammar).to_json()),
        ]),
      )
  }
}
