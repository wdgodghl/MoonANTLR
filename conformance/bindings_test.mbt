///|
fn bound_int(values : Map[String, Json], name : String) -> Int32 {
  match values.get(name) {
    Some(Number(value, ..)) => value.to_int()
    _ => 0
  }
}

///|
fn bound_bool(values : Map[String, Json], name : String) -> Bool {
  values.get(name) == Some(Json::boolean(true))
}

///|
fn bound_text(values : Map[String, Json], name : String) -> String {
  match values.get(name) {
    Some(String(value)) => value
    _ => "null"
  }
}

///|
fn bound_rule(
  event : @runtime.SemanticEvent,
  name : String,
  wanted : Int32,
) -> @runtime.RuleFrame {
  let mut index = 0
  let mut matched : @runtime.RuleFrame? = None
  let mut ordinal = 0
  for child in event.context.children {
    if child is @runtime.RuleChild(context) {
      if context.name == name {
        if wanted < 0 || ordinal == wanted {
          matched = Some(event.frame.children[index])
        }
        ordinal += 1
      }
      index += 1
    }
  }
  matched.unwrap()
}

///|
fn bound_label(
  event : @runtime.SemanticEvent,
  states : Array[Int32],
) -> @runtime.RuleFrame {
  let mut index = 0
  let mut matched : @runtime.RuleFrame? = None
  for i, child in event.context.children {
    if child is @runtime.RuleChild(_) {
      if states.contains(event.context.sources[i]) {
        matched = Some(event.frame.children[index])
      }
      index += 1
    }
  }
  matched.unwrap()
}

///|
fn bound_token_text(event : @runtime.SemanticEvent, kind : Int32) -> String {
  event.context.tokens(kind).last().unwrap().text
}

///|
fn bound_token_int(event : @runtime.SemanticEvent, kind : Int32) -> Int32 {
  let text = bound_token_text(event, kind)
  let mut value = 0
  for c in text.to_array() {
    value = value * 10 + c.to_int() - 48
  }
  value
}

///|
fn bound_frame_json(
  frame : @runtime.RuleFrame,
  build_tree~ : Bool = true,
) -> Json {
  {
    "values": Json::object(frame.values),
    "children": Json::array(
      if build_tree {
        frame.children.map(child => bound_frame_json(child))
      } else {
        []
      },
    ),
  }
}

///|
fn bound_listener_events(tree : @runtime.RecoveryTree) -> Array[String] {
  let events : Array[String] = []
  let listener : @runtime.RecoveryListener = {
    enter_rule: name => events.push("enter:" + name),
    exit_rule: name => events.push("exit:" + name),
    terminal: token => events.push("token:" + token.text),
    error: token => events.push("error:" + token.text),
  }
  listener.walk(tree)
  events
}
