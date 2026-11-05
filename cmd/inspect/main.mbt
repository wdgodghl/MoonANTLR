///|
fn main {
  let args = @env.args()
  if args.length() != 3 {
    println(
      Json::object(
        Map([
          ("ok", Json::boolean(false)),
          (
            "usage",
            Json::string(
              "moon run cmd/inspect -- <json|arithmetic|modes|csv> <source>",
            ),
          ),
        ]),
      ).stringify(),
    )
    return
  }
  let grammar = try {
    match args[1] {
      "json" => @json_grammar.grammar()
      "csv" => @csv_grammar.grammar()
      "arithmetic" => @arithmetic.grammar()
      "modes" => @modes.grammar()
      _ => raise @runtime.InvalidArgument("unknown grammar")
    }
  } catch {
    error => {
      println(
        Json::object(
          Map([
            ("ok", Json::boolean(false)),
            ("error", Json::string(error.to_repr().to_string())),
          ]),
        ).stringify(),
      )
      return
    }
  }
  println(@report.analyze(grammar, args[2]).stringify())
}
