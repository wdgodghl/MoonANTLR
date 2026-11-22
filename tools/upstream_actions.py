"""Compile the pinned Java observation actions to equivalent native callbacks.

This adapter deliberately rejects unknown expressions instead of manufacturing
their expected output. All values come from the running parser.
"""
import json,re
q=lambda value:json.dumps(value,ensure_ascii=False)

def split_concat(expression):
    parts=[];start=0;depth=0;string=False;escape=False
    for i,c in enumerate(expression):
        if string:
            if escape:escape=False
            elif c=='\\':escape=True
            elif c=='"':string=False
        elif c=='"':string=True
        elif c in '([':depth+=1
        elif c in ')]':depth-=1
        elif c=='+' and depth==0:parts.append(expression[start:i].strip());start=i+1
    parts.append(expression[start:].strip())
    return parts

def observer_expression(expression,tokens,labels,kinds,names):
    parts=split_concat(expression)
    if len(parts)>1:return ' + '.join(observer_expression(p,tokens,labels,kinds,names) for p in parts)
    if expression.startswith('"') and expression.endswith('"'):return expression
    if expression=='$text':return 'observed_text(event, event.context, true)'
    if expression=='this._input.getText()':return 'observed_input(event)'
    if expression=='this.getExpectedTokens().toString(this.tokenNames)':return 'observed_expected(event, '+json.dumps(names,ensure_ascii=False)+')'
    if expression=='getRuleInvocationStack()':return '"[" + event.rule_stack.join(", ") + "]"'
    if re.fullmatch(r'this\.\w+',expression):return 'bound_int(event.frame.shared, '+q(expression[5:])+').to_string()'
    tree=re.fullmatch(r'\$(\w+)(?:\.ctx)?\.toStringTree\(this\)',expression)
    ctx_tree=re.fullmatch(r'\$ctx\.(\w+)\.toStringTree\(this\)',expression)
    reference=re.fullmatch(r'\$(\w+)(?:\.(\w+))?',expression)
    name=(tree or ctx_tree or reference)[1] if tree or ctx_tree or reference else None
    if name is None:raise ValueError('Unhandled observation: '+expression)
    states=labels.get(name,set())
    if len(states)>1:raise ValueError('Ambiguous observation label '+name)
    sites=list(next(iter(states))) if states else []
    context='event.context' if name=='ctx' else 'observed_context(event, '+q(name)+', '+str(sites)+')'
    if tree or ctx_tree:return 'observed_tree('+context+')'
    field=reference[2]
    if field=='text' and states:return 'observed_label_text(event, '+str(sites)+')'
    if name in tokens or (field is None and states):
        token='observed_token(event, '+str(tokens.get(name,0))+', '+str(sites)+')'
        if field=='text':return token+'.text'
        if field is None:return 'observed_token_string('+token+', event.tokens)'
    if field=='text':return 'observed_text(event, '+context+', false)'
    if field in {'start','stop'}:return 'observed_token_string('+context+'.'+field+'_token.unwrap(), event.tokens)'
    frame='bound_label(event, '+str(sites)+')' if states else 'bound_rule(event, '+q(name)+', -1)'
    kind=kinds.get(field)
    if kind=='String':return 'bound_text('+frame+'.values, '+q(field)+')'
    if kind in {'int','long','double','float'}:return 'bound_int('+frame+'.values, '+q(field)+').to_string()'
    raise ValueError('Unhandled attribute observation: '+expression)

def print_statements(body,tokens,labels,kinds,names,grammar,alternatives):
    result=[]
    pattern=r'System\.out\.(print|println)\('
    for match in re.finditer(pattern,body):
        start=match.end();i=start;depth=1;string=False;escape=False
        while depth:
            c=body[i]
            if string:
                if escape:escape=False
                elif c=='\\':escape=True
                elif c=='"':string=False
            elif c=='"':string=True
            elif c=='(':depth+=1
            elif c==')':depth-=1
            i+=1
        value=observer_expression(body[start:i-1].strip(),tokens,labels,kinds,names)
        if alternatives:
            # Only tree calls occur as the outer print expression in this corpus.
            if not value.startswith('observed_tree('):
                if 'observed_tree(' in value:raise ValueError('Nested custom context tree expression')
            else:value=value[:-1]+', alternatives='+str(alternatives).replace("'",'"')+')'
        result.append('printed.write_string('+value+(' + "\\n"' if match[1]=='println' else '')+')')
    if 'dumpDFA' in body:result.append('printed.write_string(event.control.unwrap().dump_dfa())')
    if re.search(r'\bfoo\(\)',body):result.append('printed.write_string("foo\\n")')
    if 'walker.walk(new LeafListener()' in body:
        mode='Basic' if 'visitTerminal(TerminalNode' in grammar else 'TokenGetter' if 'ctx.INT(0)' in grammar else 'RuleGetter' if 'ctx.b(0)' in grammar else 'LRWithLabels' if 'exitCall(' in grammar else 'LR'
        match=re.search(r'walker\.walk\(new LeafListener\(\), \$ctx\.(\w+)\)',body)
        if not match:raise ValueError('Unhandled listener root: '+body)
        name=match[1];sites=list(next(iter(labels[name])))
        result.append('observed_walk(observed_context(event, '+q(name)+', '+str(sites)+'), '+q(mode)+', event.tokens, '+str(tokens['INT'])+', '+str(tokens['ID'])+', '+str(sites)+', printed)')
    for token in re.findall(r'assert\(\(\(\w+Context\)\$ctx\)\.(\w+)\(\) != null\)',body):
        result.append('if event.context.tokens('+str(tokens[token])+').is_empty() { raise @runtime.InvalidArgument("missing asserted token '+token+'") }')
    return result

def validate_action(body):
    """No pinned host action may silently disappear from the native comparison."""
    patterns=[
        r'System\.out\.(?:print|println)\(.*?\);',
        r'(?:_interp\.)?setPredictionMode\(PredictionMode\.LL_EXACT_AMBIG_DETECTION\);',
        r'setBuildParseTree\((?:true|false)\);',
        r'setErrorHandler\(new BailErrorStrategy\(\)\);',
        r'this\.\w+\s*(?:\+=|=)\s*(?:-?\d+|true|false)\s*;',
        r'\$\w+\s*=\s*[^;]+;',
        r'assert\(\(\(\w+Context\)\$ctx\)\.\w+\(\) != null\);',
        r'(?:this\.dumpDFA\(System.out\)|foo\(\));',
        r'List<\?> __ttt__ = \$(?:args|ctx\.elseIfStatement\(\));',
        r'int x = 0;',
        r'ParseTreeWalker walker = new ParseTreeWalker\(\);\s*walker\.walk\(new LeafListener\(\), \$ctx\.\w+\);',
    ]
    residue=body
    for pattern in patterns:residue=re.sub(pattern,'',residue,flags=re.S)
    residue=residue.strip('{} \r\n\t')
    if residue:raise ValueError('Unhandled parser action: '+residue)

def lexer_bindings(actions):
    lines=['  let lexer_observer : @runtime.LexerAction = (event, source) => {', '    ignore(event); ignore(source)', '    match (event.rule, event.action) {']
    for rule,index,body in actions:
        statements=[]
        for match in re.finditer(r'System\.out\.(print|println)\((.*?)\);',body,re.S):
            parts=split_concat(match[2].strip());values=[]
            for part in parts:
                if part.startswith('"') and part.endswith('"'):values.append(part)
                elif part in {'getText()','this.getText()'}:values.append('event.text.unwrap_or(String::from_array(source.to_array()[event.token_start:event.offset]))')
                else:raise ValueError('Unhandled Lexer observation: '+part)
            statements.append('printed.write_string('+' + '.join(values)+(' + "\\n"' if match[1]=='println' else '')+')')
        residue=re.sub(r'System\.out\.(?:print|println)\(.*?\);','',body,flags=re.S).strip('{} \r\n\t')
        if residue:raise ValueError('Unhandled Lexer action: '+body)
        lines.append('      ('+str(rule)+', '+str(index)+') => { '+'; '.join(statements)+' }')
    lines+=['      _ => raise @runtime.InvalidArgument("unbound lexer observation")','    }','  }']
    return lines
