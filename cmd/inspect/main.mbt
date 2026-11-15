///|
fn main {
  let args = cli_args()
  let from_file = args.length() == 4 && args[2] == "--file"
  let from_argument = args.length() == 3 && args[2] != "--file"
  if !from_argument && !from_file {
    println(
      Json::object(
        Map([
          ("ok", Json::boolean(false)),
          (
            "usage",
            Json::string(
              "moon run cmd/inspect -- <json|arithmetic|modes|csv> <source | --file path>",
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
  let source = if from_file {
    try {
      let bytes = @fs.read_file_to_bytes(args[3])
      @utf8.decode(bytes[:])
    } catch {
      error => {
        let message = match error {
          @fs.IOError::IOError(message) => message
          _ => "file is not valid UTF-8"
        }
        let report : Json = {
          "ok": Json::boolean(false),
          "diagnostic": {
            "code": Json::string("file_error"),
            "path": Json::string(args[3]),
            "message": Json::string(message),
          },
        }
        println(report.stringify())
        return
      }
    }
  } else {
    args[2]
  }
  println(@report.analyze(grammar, source).stringify())
}
