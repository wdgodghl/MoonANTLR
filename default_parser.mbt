// Error strategy adapted from ANTLR 4.13.2 DefaultErrorStrategy.java.
// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
// BSD-3-Clause: licenses/ANTLR-LICENSE.txt.

///|
pub(all) struct DefaultParseResult {
  context : RuleContext
  frame : RuleFrame?
  tree : RecoveryTree
  diagnostics : Array[Diagnostic]
  next_token : Token
  prediction : PredictionStatistics
}

///|
priv struct DefaultParser {
  grammar : Grammar
  build_tree : Bool
  input : ParserInput
  predictor : Predictor
  budget : Budget
  diagnostics : Array[Diagnostic]
  action : ParserAction?
  semantics : RuleSemantics?
  predicate : ParserPredicate?
  mut pos : Int32
  mut recovering : Bool
  mut last_error : Int32
  mut lexical_errors : Int32
  error_states : Array[Int32]
}

///|
/// Keep discarded terminal nodes visible through context token accessors.
fn include_error_tokens(
  context : RuleContext,
  recovered : Array[RecoveryTree],
) -> RuleContext {
  if !context.build_tree {
    return context
  }
  let children : Array[ContextChild] = []
  let sources : Array[Int32] = []
  let mut cursor = 0
  for node in recovered {
    match node {
      TokenNode(token) | ErrorNode(token, _) => {
        let matched = cursor < context.children.length() &&
          (match context.children[cursor] {
            TokenChild(existing) => existing == token
            _ => false
          })
        children.push(TokenChild(token))
        sources.push(if matched { context.sources[cursor] } else { -1 })
        if matched {
          cursor += 1
        }
      }
      RuleNode(_, _) =>
        if cursor < context.children.length() {
          children.push(context.children[cursor])
          sources.push(context.sources[cursor])
          cursor += 1
        }
    }
  }
  { ..context, children, sources, }
}

///|
fn DefaultParser::next_set(
  self : DefaultParser,
  state : Int32,
  outer : Int32,
) -> Array[Int32] raise RuntimeError {
  let id = self.predictor.start(state, 0, outer, collect=false)
  let dfa = self.predictor.states[id]
  let found : Map[Int32, Bool] = Map([])
  if !dfa.accepted.is_empty() {
    found[if outer == 0 { -2 } else { -1 }] = true
  }
  for cfg in dfa.configs {
    let edge = self.grammar.parser.states[cfg.state].edges[cfg.edge]
    for kind in -1..<=self.grammar.parser.max_token {
      if kind != 0 && self.grammar.parser.matches(edge, kind) {
        found[kind] = true
      }
    }
  }
  let result = found.keys().collect()
  result.sort()
  result
}

///|
fn DefaultParser::report(
  self : DefaultParser,
  expected : Array[Int32],
  index? : Int32,
) -> Unit raise RuntimeError {
  self.collect_lexer_errors()
  if !self.recovering {
    let token = self.input.token(index.unwrap_or(self.pos))
    self.diagnostics.push(
      SyntaxError(token.line, token.column, expected.filter(k => k != -2)).diagnostic(
        self.grammar,
      ),
    )
  }
  self.recovering = true
}

///|
fn DefaultParser::recognition(
  self : DefaultParser,
  rule : Int32,
  expected : Array[Int32],
  index? : Int32,
  kind~ : String = "InputMismatchException",
) -> Unit raise RuntimeError {
  if self.grammar.parser.rule_exceptions.contains(rule) {
    let token = self.input.token(index.unwrap_or(self.pos))
    raise RecognitionError(
      kind,
      token.line,
      token.column,
      expected.filter(kind => kind != -2),
    )
  }
  self.report(expected, index?)
}

///|
fn DefaultParser::collect_lexer_errors(self : DefaultParser) -> Unit {
  if self.input.lexer is Some(lexer) {
    let errors = lexer.diagnostics()
    for index in self.lexical_errors..<errors.length() {
      self.diagnostics.push(errors[index].diagnostic(self.grammar))
    }
    self.lexical_errors = errors.length()
  }
}

///|
fn DefaultParser::discard(
  self : DefaultParser,
  children : Array[RecoveryTree],
) -> Unit raise RuntimeError {
  let token = self.input.token(self.pos)
  if self.build_tree {
    children.push(ErrorNode(token, "deleted"))
  }
  if token.kind != -1 {
    self.pos += 1
  }
}

///|
fn DefaultParser::recover(
  self : DefaultParser,
  state : Int32,
  outer : Int32,
  children : Array[RecoveryTree],
) -> Unit raise RuntimeError {
  if self.last_error == self.pos && self.error_states.contains(state) {
    self.discard(children)
  }
  if self.last_error != self.pos {
    self.error_states.clear()
  }
  self.last_error = self.pos
  self.error_states.push(state)
  let follow : Array[Int32] = []
  let mut current = outer
  while current != 0 {
    let ret = self.predictor.returns[current]
    for kind in self.next_set(ret.state, 0) {
      if kind != -2 && !follow.contains(kind) {
        follow.push(kind)
      }
    }
    current = ret.parent
  }
  while true {
    self.budget.tick()
    let kind = self.input.token(self.pos).kind
    if kind == -1 || follow.contains(kind) {
      break
    }
    self.discard(children)
  }
}

///|
fn DefaultParser::rule(
  self : DefaultParser,
  rule : Int32,
  precedence : Int32,
  outer : Int32,
  depth : Int32,
  seed? : RuleFrame,
  unwind? : Ref[(RuleContext, RecoveryTree, RuleFrame?)?],
) -> (RuleContext, RecoveryTree, RuleFrame?) raise RuntimeError {
  self.budget.tick()
  let atn = self.grammar.parser
  let mut state_id = atn.starts[rule]
  let mut context : RuleContext = {
    name: self.grammar.rules[rule],
    children: [],
    sources: [],
    path: [],
    recovered_captures: Map([]),
    build_tree: self.build_tree,
    labels: [],
  }
  let mut frame = match (self.semantics, seed) {
    (Some(bindings), Some(seed)) => Some((bindings.enter)(rule, seed))
    _ => None
  }
  let mut children : Array[RecoveryTree] = []
  errdefer (if unwind is Some(sink) {
    sink.val = Some(
      (
        include_error_tokens(context, children),
        RuleNode(context.name, children.copy()),
        frame,
      ),
    )
  })
  frame = self.lifecycle(rule, "init", context, frame)
  let mut finalized = false
  errdefer (if !finalized {
    frame = self.lifecycle(rule, "finally", context, frame)
  })
  try {
    while true {
      self.budget.tick()
      let state = atn.states[state_id]
      context = context.enter(state_id)
      if state.kind == 7 {
        break
      }
      let token = self.input.token(self.pos)
      // sync is emitted at decisions and loop backs, before adaptive prediction.
      if !self.recovering &&
        (
          state.kind == 3 ||
          state.kind == 4 ||
          state.kind == 5 ||
          state.kind == 10 ||
          state.kind == 9 ||
          state.kind == 11
        ) {
        let immediate = self.next_set(state_id, 0)
        if !immediate.contains(token.kind) && !immediate.contains(-2) {
          let expected = self.next_set(state_id, outer)
          if !expected.contains(self.input.token(self.pos + 1).kind) &&
            state.kind != 9 &&
            state.kind != 11 {
            self.recognition(rule, expected)
          } else {
            self.report(expected)
          }
          if expected.contains(self.input.token(self.pos + 1).kind) {
            self.discard(children)
            self.recovering = false
          } else if state.kind == 9 || state.kind == 11 {
            let follow = expected.copy()
            let mut current = outer
            while current != 0 {
              let ret = self.predictor.returns[current]
              for kind in self.next_set(ret.state, 0) {
                if kind != -2 {
                  follow.push(kind)
                }
              }
              current = ret.parent
            }
            while self.input.token(self.pos).kind != -1 &&
                  !follow.contains(self.input.token(self.pos).kind) {
              self.discard(children)
            }
          } else {
            self.recover(state_id, outer, children)
            break
          }
        }
      }
      context = include_error_tokens(context, children)
      // sync may have discarded a token; predicates observe the new lookahead.
      let token = self.input.token(self.pos)
      let event_pos = self.pos
      let event = frame.map(frame => SemanticEvent::{
        rule,
        site: state_id,
        context,
        next_token: token,
        frame: frame.snapshot(),
        tokens: self.input.original,
        lookahead_fn: offset => self.input.token(event_pos + offset - 1),
      })
      let choice = if state.edges.length() > 1 {
        if self.semantics is Some(_) || self.predicate is Some(_) {
          self.predictor.states.clear()
          self.predictor.starts.clear()
          self.predictor.interned.clear()
          self.predictor.check = Some((owner, index, dependent) => {
            if dependent && owner != rule {
              true
            } else if self.semantics is Some(bindings) && event is Some(event) {
              (bindings.predicate)(event, index)
            } else if self.predicate is Some(check) {
              check(owner, index, token)
            } else {
              true
            }
          })
        }
        let alts = self.predictor.predict(
          state_id,
          precedence,
          outer,
          self.input,
          self.pos,
          terminal_loop=!state.non_greedy &&
            (state.kind == 10 || state.kind == 11),
        )
        if alts.is_empty() {
          self.recognition(
            rule,
            self.next_set(state_id, outer),
            index=self.predictor.failure_pos,
            kind="NoViableAltException",
          )
          self.recover(state_id, outer, children)
          break
        }
        alts.sort()
        alts[0]
      } else {
        0
      }
      let edge = state.edges[choice]
      match edge.kind {
        1 =>
          if atn.is_precedence_decision(state_id) &&
            atn.states[edge.target].kind != 12 {
            frame = match (self.semantics, frame) {
              (Some(bindings), Some(previous)) =>
                Some({
                  ..(bindings.wrap)(rule, previous),
                  shared: previous.shared,
                })
              _ => None
            }
            children = if self.build_tree {
              [RuleNode(context.name, children)]
            } else {
              []
            }
            context = {
              name: context.name,
              children: if self.build_tree {
                [RuleChild(context)]
              } else {
                []
              },
              sources: if self.build_tree {
                [-1]
              } else {
                []
              },
              path: [],
              recovered_captures: Map([]),
              build_tree: self.build_tree,
              labels: if self.build_tree {
                []
              } else {
                [(-1, RuleChild(context))]
              },
            }
          }
        3 => {
          let next_outer = self.predictor.push(edge.target, precedence, outer)
          let seed = match (self.semantics, event) {
            (Some(bindings), Some(event)) =>
              Some(RuleFrame::{
                values: (bindings.arguments)(event, edge.b),
                shared: frame.unwrap().shared,
                children: [],
              })
            _ => None
          }
          let partial : Ref[(RuleContext, RecoveryTree, RuleFrame?)?] = Ref(
            None,
          )
          let (child, tree, child_frame) = {
            errdefer (if partial.val is Some((child, tree, child_frame)) {
              // A throwing call has a tree child, but its element label was
              // never assigned by the generated call expression.
              context = context.append(RuleChild(child), -2)
              if self.build_tree {
                children.push(tree)
              }
              if frame is Some(parent) && child_frame is Some(child_frame) {
                parent.children.push(child_frame)
              }
            })
            self.rule(
              edge.b,
              edge.c,
              next_outer,
              depth + 1,
              seed?,
              unwind=partial,
            )
          }
          if frame is Some(parent) && child_frame is Some(child) {
            parent.children.push(child)
            frame = Some({ ..parent, shared: child.shared, })
          }
          context = context.append(RuleChild(child), state_id)
          if self.build_tree {
            children.push(tree)
          }
        }
        4 => {
          let accepted = if self.semantics is Some(bindings) &&
            event is Some(event) {
            (bindings.predicate)(event, edge.b)
          } else if self.predicate is Some(check) {
            check(edge.a, edge.b, token)
          } else {
            false
          }
          if !accepted {
            self.recognition(rule, [], kind="FailedPredicateException")
            self.recover(state_id, outer, children)
            break
          }
        }
        6 => {
          if self.semantics is Some(bindings) &&
            event is Some(event) &&
            atn.parser_actions.get(state_id) is Some(action) {
            frame = Some(
              (bindings.action)({ ..event, frame: frame.unwrap(), }, action),
            )
          }
          if self.action is Some(execute) &&
            atn.parser_actions.get(state_id) is Some(action) {
            execute({
              rule,
              action,
              context,
              next_token: self.input.token(self.pos),
            })
          }
        }
        10 =>
          if edge.a < precedence {
            self.recognition(
              rule,
              self.next_set(state_id, outer),
              kind="FailedPredicateException",
            )
            self.recover(state_id, outer, children)
            break
          }
        2 | 5 | 7 | 8 | 9 => {
          let mut matched = self.input.token(self.pos)
          if !atn.matches(edge, matched.kind) {
            let expected = self.next_set(state_id, outer)
            if atn.matches(edge, self.input.token(self.pos + 1).kind) {
              self.report(expected)
              self.discard(children)
              matched = self.input.token(self.pos)
            } else if self.next_set(edge.target, outer).contains(matched.kind) ||
              (
                matched.kind == -1 &&
                self.next_set(edge.target, outer).contains(-2)
              ) {
              self.report(expected)
              let kind = if expected.is_empty() { 0 } else { expected[0] }
              let location = if matched.kind == -1 && self.pos > 0 {
                self.input.token(self.pos - 1)
              } else {
                matched
              }
              let inserted : Token = {
                ..location,
                kind,
                text: "<missing " + self.grammar.token_name(kind) + ">",
                start: -1,
                end: 0,
                channel: 0,
              }
              if edge.kind == 5 {
                context = context.append(TokenChild(inserted), state_id)
                if self.build_tree {
                  children.push(ErrorNode(inserted, "inserted"))
                }
              } else {
                // Java's generated set match uses recoverInline's return value
                // for a label, without Parser.match's synthetic error-node step.
                let captures = context.recovered_captures.copy()
                let values = captures.get(state_id).unwrap_or([]).copy()
                values.push(
                  (
                    if self.build_tree {
                      context.children.length()
                    } else {
                      context.labels.length()
                    },
                    inserted,
                  ),
                )
                captures[state_id] = values
                context = { ..context, recovered_captures: captures, }
              }
              state_id = edge.target
              continue
            } else {
              self.recognition(rule, expected)
              self.recover(state_id, outer, children)
              break
            }
          }
          self.recovering = false
          self.error_states.clear()
          self.last_error = -1
          context = context.append(TokenChild(matched), state_id)
          if self.build_tree {
            children.push(TokenNode(matched))
          }
          if matched.kind != -1 {
            self.pos += 1
          }
        }
        _ => raise Unsupported("default parser requires action-free prediction")
      }
      state_id = edge.target
    }
    context = include_error_tokens(context, children)
    if atn.states[state_id].kind == 7 {
      frame = self.lifecycle(rule, "after", context, frame)
    }
  } catch {
    error => {
      guard atn.rule_exceptions.contains(rule) &&
        self.semantics is Some(bindings) &&
        bindings.handle_exception is Some(handle) &&
        frame is Some(current) else {
        raise error
      }
      let event_pos = self.pos
      frame = Some(
        handle(
          {
            rule,
            site: state_id,
            context: include_error_tokens(context, children),
            frame: current,
            next_token: self.input.token(self.pos),
            tokens: self.input.original,
            lookahead_fn: offset => self.input.token(event_pos + offset - 1),
          },
          error,
        ),
      )
    }
  }
  finalized = true
  frame = self.lifecycle(rule, "finally", context, frame)
  (
    include_error_tokens(context, children),
    RuleNode(context.name, children),
    frame,
  )
}

///|
fn DefaultParser::lifecycle(
  self : DefaultParser,
  rule : Int32,
  phase : String,
  context : RuleContext,
  frame : RuleFrame?,
) -> RuleFrame? raise RuntimeError {
  guard self.grammar.parser.rule_actions.get((rule, phase)) is Some(action) else {
    return frame
  }
  let next_token = self.input.token(self.pos)
  let event_pos = self.pos
  let frame = if self.semantics is Some(bindings) && frame is Some(frame) {
    Some(
      (bindings.action)(
        {
          rule,
          site: self.grammar.parser.starts[rule],
          context,
          frame,
          next_token,
          tokens: self.input.original,
          lookahead_fn: offset => self.input.token(event_pos + offset - 1),
        },
        action,
      ),
    )
  } else {
    frame
  }
  if self.action is Some(execute) {
    execute({ rule, action, context, next_token, })
  }
  frame
}

///|
/// Parse one rule with local insertion/deletion and invocation-context recovery.
/// Host actions execute on the committed path, including recovered paths.
pub fn Grammar::parse_default(
  self : Grammar,
  source : String,
  prediction_mode~ : PredictionMode = LL,
  build_tree~ : Bool = true,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
  lexer_predicate? : LexerPredicate,
  lexer_context_predicate? : LexerContextPredicate,
  lexer_action? : LexerAction,
  parser_action? : ParserAction,
  predicate? : ParserPredicate,
  semantics? : RuleSemantics,
  arguments~ : Map[String, Json] = Map([]),
  shared~ : Map[String, Json] = Map([]),
) -> DefaultParseResult raise RuntimeError {
  let cursor = self.lexer_cursor(
    source,
    work_limit~,
    lexer_predicate?,
    lexer_context_predicate?,
    lexer_action?,
    recover=true,
  )
  self.default_input(
    { visible: [], original: [], lexer: Some(cursor), },
    prediction_mode~,
    build_tree~,
    start_rule~,
    work_limit~,
    parser_action?,
    predicate?,
    semantics?,
    arguments~,
    shared~,
  )
}

///|
/// Use a prepared channel buffer and retain physical indices for predicates.
pub fn Grammar::parse_default_tokens(
  self : Grammar,
  tokens : Array[Token],
  original_tokens? : Array[Token],
  channel~ : Int32 = 0,
  prediction_mode~ : PredictionMode = LL,
  build_tree~ : Bool = true,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
  parser_action? : ParserAction,
  predicate? : ParserPredicate,
  semantics? : RuleSemantics,
  arguments~ : Map[String, Json] = Map([]),
  shared~ : Map[String, Json] = Map([]),
) -> DefaultParseResult raise RuntimeError {
  let visible = TokenStream::new(tokens, channel~).visible_tokens()
  self.default_input(
    { visible, original: original_tokens.unwrap_or(tokens), lexer: None, },
    prediction_mode~,
    build_tree~,
    start_rule~,
    work_limit~,
    parser_action?,
    predicate?,
    semantics?,
    arguments~,
    shared~,
  )
}

///|
fn Grammar::default_input(
  self : Grammar,
  input : ParserInput,
  prediction_mode~ : PredictionMode = LL,
  build_tree~ : Bool = true,
  start_rule~ : Int32 = 0,
  work_limit~ : Int32 = 1_000_000,
  parser_action? : ParserAction,
  predicate? : ParserPredicate,
  semantics? : RuleSemantics,
  arguments~ : Map[String, Json] = Map([]),
  shared~ : Map[String, Json] = Map([]),
) -> DefaultParseResult raise RuntimeError {
  if self.parser.kind != 1 || self.rules.length() != self.parser.starts.length() {
    raise InvalidAtn("parser ATN and matching rule-name table required")
  }
  self.parser.validate_supported(
    custom_parser_actions=parser_action is Some(_) || semantics is Some(_),
    predicates=predicate is Some(_) || semantics is Some(_),
    contextual_predicates=semantics is Some(_),
    rule_exceptions=match semantics {
      Some(bindings) => bindings.handle_exception is Some(_)
      None => false
    },
  )
  if start_rule < 0 || start_rule >= self.rules.length() {
    raise InvalidArgument("unknown start rule")
  }
  let budget : Budget = { remaining: work_limit, }
  let parser : DefaultParser = {
    grammar: self,
    build_tree,
    input,
    predictor: Predictor::new(self.parser, budget),
    budget,
    diagnostics: [],
    action: parser_action,
    semantics,
    predicate,
    pos: 0,
    recovering: false,
    last_error: -1,
    lexical_errors: 0,
    error_states: [],
  }
  parser.predictor.mode = prediction_mode
  let seed = if semantics is Some(_) {
    Some(RuleFrame::{
      values: arguments.copy(),
      shared: shared.copy(),
      children: [],
    })
  } else {
    None
  }
  let (context, tree, frame) = parser.rule(start_rule, 0, 0, 0, seed?)
  let next_token = parser.input.token(parser.pos)
  parser.collect_lexer_errors()
  let diagnostics = parser.diagnostics
  {
    context,
    frame,
    tree,
    diagnostics,
    next_token,
    prediction: {
      decisions: parser.predictor.decisions,
      full_context_fallbacks: parser.predictor.fallbacks,
      dfa_states: parser.predictor.states.length(),
      dfa_hits: parser.predictor.hits,
      max_lookahead: parser.predictor.max_lookahead,
    },
  }
}
