///|
fn observed_tree(
  node : @runtime.RuleContext,
  alternatives~ : Array[(String, Int32, Array[Int32])] = [],
) -> String {
  let mut name = node.name
  for (rule, alt, sites) in alternatives {
    if rule == node.name && node.path.any(state => sites.contains(state)) {
      name = rule + ":" + alt.to_string()
      break
    }
  }
  if node.children.is_empty() {
    return name
  }
  "(" +
  name +
  " " +
  node.children
  .map(child => {
    match child {
      @runtime.TokenChild(token) => observed_escape(token.text)
      @runtime.RuleChild(context) => observed_tree(context, alternatives~)
    }
  })
  .join(" ") +
  ")"
}

///|
fn observed_label_text(
  event : @runtime.SemanticEvent,
  states : Array[Int32],
) -> String {
  let mut value = ""
  for (state, child) in event.context.labels {
    if states.contains(state) {
      value = match child {
        @runtime.TokenChild(token) => token.text
        @runtime.RuleChild(context) => observed_text(event, context, false)
      }
    }
  }
  let recovered = event.context.select_tokens(states)
  if !recovered.is_empty() {
    value = recovered.last().unwrap().text
  }
  value
}

///|
fn observed_context(
  event : @runtime.SemanticEvent,
  name : String,
  states : Array[Int32],
) -> @runtime.RuleContext {
  let mut found : @runtime.RuleContext? = None
  for (state, child) in event.context.labels {
    if child is @runtime.RuleChild(context) &&
      (if states.is_empty() {
        context.name == name
      } else {
        states.contains(state)
      }) {
      found = Some(context)
    }
  }
  found.unwrap()
}

///|
fn observed_token(
  event : @runtime.SemanticEvent,
  kind : Int32,
  states : Array[Int32],
) -> @runtime.Token {
  if states.is_empty() {
    return event.context.tokens(kind).last().unwrap()
  }
  event.context.select_tokens(states).last().unwrap()
}

///|
fn observed_token_string(
  token : @runtime.Token,
  tokens : Array[@runtime.Token],
) -> String {
  let mut index = -1
  for i, candidate in tokens {
    if candidate == token {
      index = i
      break
    }
  }
  let text = observed_escape(token.text)
  "[@" +
  index.to_string() +
  "," +
  token.start.to_string() +
  ":" +
  (token.end - 1).to_string() +
  "='" +
  text +
  "',<" +
  token.kind.to_string() +
  ">" +
  (if token.channel == 0 {
    ""
  } else {
    ",channel=" + token.channel.to_string()
  }) +
  "," +
  token.line.to_string() +
  ":" +
  token.column.to_string() +
  "]"
}

///|
fn observed_escape(text : String) -> String {
  let out = StringBuilder()
  for c in text.to_array() {
    match c {
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      _ => out.write_char(c)
    }
  }
  out.to_string()
}

///|
fn observed_text(
  event : @runtime.SemanticEvent,
  node : @runtime.RuleContext,
  current : Bool,
) -> String {
  guard node.start_token is Some(start) else { return "" }
  let mut stop = node.stop_token
  if current {
    for token in event.tokens {
      if token.channel == 0 && token.start < event.next_token.start {
        stop = Some(token)
      }
    }
  }
  guard stop is Some(stop) && start.start <= stop.start else { return "" }
  event.tokens
  .filter(token => {
    token.kind != -1 && token.start >= start.start && token.start <= stop.start
  })
  .map(token => token.text)
  .join("")
}

///|
fn observed_input(
  event : @runtime.SemanticEvent,
) -> String raise @runtime.RuntimeError {
  let mut offset = 1
  while event.lookahead(offset).kind != -1 {
    offset += 1
  }
  event.tokens
  .filter(token => token.kind != -1)
  .map(token => token.text)
  .join("")
}

///|
fn observed_expected(
  event : @runtime.SemanticEvent,
  names : Array[String],
) -> String raise @runtime.RuntimeError {
  let kinds = event.expected_tokens()
  let names = kinds.map(kind => {
    if kind == -1 {
      "<EOF>"
    } else if kind >= 0 && kind < names.length() {
      names[kind]
    } else {
      kind.to_string()
    }
  })
  if names.length() == 1 {
    names[0]
  } else {
    "{" + names.join(", ") + "}"
  }
}

///|
fn observed_pred(output : StringBuilder, value : Bool) -> Bool {
  output.write_string("eval=" + value.to_string() + "\n")
  value
}

///|
// Equivalent implementations of the five listeners in pinned Java.test.stg.
// Child getters and invocation-state stacks are read from the parsed context.
fn observed_walk(
  node : @runtime.RuleContext,
  mode : String,
  tokens : Array[@runtime.Token],
  int_kind : Int32,
  id_kind : Int32,
  stack : Array[Int32],
  output : StringBuilder,
) -> Unit {
  for i, child in node.children {
    match child {
      @runtime.TokenChild(token) =>
        if mode == "Basic" {
          output.write_string(token.text + "\n")
        }
      @runtime.RuleChild(context) =>
        observed_walk(
          context,
          mode,
          tokens,
          int_kind,
          id_kind,
          [node.sources[i]] + stack,
          output,
        )
    }
  }
  if mode == "TokenGetter" && node.name == "a" {
    if node.children.length() == 2 {
      let values = node.tokens(int_kind).map(token => token.text)
      output.write_string(
        values[0] + " " + values[1] + " [" + values.join(", ") + "]\n",
      )
    } else {
      output.write_string(
        observed_token_string(node.tokens(id_kind)[0], tokens) + "\n",
      )
    }
  } else if mode == "RuleGetter" && node.name == "a" {
    let children = node.rules("b")
    let first = children[0].start_token.unwrap().text
    output.write_string(
      if node.children.length() == 2 {
        first + " " + children[1].start_token.unwrap().text + " " + first + "\n"
      } else {
        first + "\n"
      },
    )
  } else if mode == "LR" && node.name == "e" {
    if node.children.length() == 3 {
      let children = node.rules("e")
      let first = children[0].start_token.unwrap().text
      output.write_string(
        first + " " + children[1].start_token.unwrap().text + " " + first + "\n",
      )
    } else {
      output.write_string(node.tokens(int_kind)[0].text + "\n")
    }
  } else if mode == "LRWithLabels" && node.name == "e" {
    if node.children.length() == 4 {
      let first = node.rules("e")[0].start_token.unwrap().text
      let mut invocation = -1
      for i, child in node.children {
        if child is @runtime.RuleChild(context) && context.name == "eList" {
          invocation = node.sources[i]
        }
      }
      output.write_string(
        first +
        " [" +
        ([invocation] + stack).map(state => state.to_string()).join(" ") +
        "]\n",
      )
    } else {
      output.write_string(node.tokens(int_kind)[0].text + "\n")
    }
  }
}
