///|
fn expression_ast(node : @grammar.TypedExpressionContext) -> Json {
  match node.alternative() {
    Some("Number") => { "number": Json::string(node.label_number()[0].text) }
    Some("Group") => expression_ast(node.label_inner()[0])
    _ =>
      {
        "op": Json::string(node.label_op()[0].text),
        "left": expression_ast(node.label_left()[0]),
        "right": expression_ast(node.label_right()[0]),
      }
  }
}

///|
/// Analyze a DSL document and return JSON for the browser host.
#export_name("analyze")
pub fn analyze(source : String) -> String {
  let report : Json = try {
    let grammar = @grammar.grammar()
    let separator = grammar.tokenize(";")[0].kind
    let parsed = grammar.parse_recovering(source, sync_tokens=[separator])
    let parser = @grammar.TypedParser::new()
    let ast = if parsed.diagnostics.is_empty() {
      parser
      .parse_document(source)
      .label_entries()
      .map(entry => {
        let item : Json = {
          "name": Json::string(entry.label_key()[0].text),
          "value": expression_ast(entry.label_value()[0]),
        }
        item
      })
    } else {
      []
    }
    {
      "complete": Json::boolean(parsed.complete),
      "tree": parsed.context
      .map(context => context.to_tree().to_json())
      .unwrap_or(Json::null()),
      "diagnostics": Json::array(
        parsed.diagnostics.map(diagnostic => diagnostic.to_json()),
      ),
      "ast": Json::array(ast),
    }
  } catch {
    @runtime.RuntimeError::LexicalError(line, column, message) =>
      {
        "complete": Json::boolean(false),
        "diagnostics": [
          {
            "line": Json::number(line.to_double()),
            "column": Json::number(column.to_double()),
            "message": Json::string(message),
          },
        ],
      }
    _ =>
      {
        "complete": Json::boolean(false),
        "message": Json::string("Unable to analyze input"),
      }
  }
  report.stringify()
}
