"""Reproduce structural behavior of pinned upstream ANTLR runtime descriptors.

Original Java host observation actions remain in the generated Java reference.
MoonBit binds these observation-only actions to no-ops; tree/Token/diagnostic
observations are asserted directly instead of comparing JVM debug-DFA dumps.
"""
import argparse,ast,base64,concurrent.futures,hashlib,json,os,re,subprocess
from collections import Counter
from pathlib import Path
from build_target import build
from generate import ANTLR_SHA256,read_interp
ROOT=Path(__file__).resolve().parents[1]
EXPECTED_CATEGORIES={'CompositeLexers':2,'CompositeParsers':15,'FullContextParsing':15,
    'LeftRecursion':98,'LexerErrors':12,'LexerExec':42,'Listeners':7,'ParseTrees':10,
    'ParserErrors':34,'ParserExec':50,'SemPredEvalLexer':8,'SemPredEvalParser':26,'Sets':31}

def run(args,**kwargs):
    return subprocess.run(list(map(str,args)),check=True,encoding='utf8',capture_output=True,**kwargs)

def sections(path):
    # RuntimeTestDescriptorParser.java: recognize only known section names,
    # preserve quoted whitespace and append LF to unquoted multiline values.
    parts=re.split(r'^\[(notes|type|grammar|slaveGrammar|start|input|output|errors|flags|skip)\][ \t]*$',path.read_text(encoding='utf8'),flags=re.M)
    data={}
    for key,value in zip(parts[1::2],parts[2::2]):
        value=value.strip(' \t\r\n\v\f')
        if value.startswith('"""'):value=value.replace('"""','')
        elif '\n' in value:value+='\n'
        if key=='slaveGrammar':data.setdefault(key,[]).append(value)
        else:data[key]=value
    data.setdefault('input','')
    data['type']=data['type'].replace('Composite','')
    return data

def quoted(value):return json.dumps(value,ensure_ascii=False)

def package_key(key):
    # MSVC repeats the package basename in object and executable paths.
    # Bound it so native tests work in ordinary Windows checkout directories.
    return key if len(key)<=60 else key[:40]+'_'+hashlib.sha256(key.encode()).hexdigest()[:8]
def tuples(tokens):return ', '.join('('+', '.join(quoted(value) for value in token)+')' for token in tokens)

def exported(path,name):
    source=path.read_text(encoding='utf8')
    marker='pub fn '+name+'('
    if marker not in source:return []
    body=source.split(marker,1)[1].split('{',1)[1]
    begin=body.index('[');depth=0;quoted_string=False;escaped=False
    for index in range(begin,len(body)):
        char=body[index]
        if quoted_string:
            if escaped:escaped=False
            elif char=='\\':escaped=True
            elif char=='"':quoted_string=False
        elif char=='"':quoted_string=True
        elif char=='[':depth+=1
        elif char==']':
            depth-=1
            if depth==0:return ast.literal_eval(body[begin:index+1])
    raise ValueError('Unclosed generated metadata array')

def predicate_expression(expression,tokens):
    expression=expression.strip()[1:].rsplit('}',1)[0].strip()
    if expression.startswith('this.pred('):expression=expression[len('this.pred('):-1]
    if expression in {'true','false'}:return expression
    match=re.fullmatch(r'this\._input\.LT\((\d+)\)\.getText\(\)\.equals\((".*?")\)',expression)
    if match:return f'event.lookahead({match[1]}).text == {match[2]}'
    match=re.fullmatch(r'this\._input\.LA\((\d+)\)\s*!=\s*\w+\.(\w+)',expression)
    if match:return f'event.lookahead({match[1]}).kind != {tokens[match[2]]}'
    expression=re.sub(r'this\.(\w+)',lambda m:'bound_int(event.frame.shared, '+quoted(m[1])+')',expression)
    expression=re.sub(r'\$(\w+)',lambda m:'bound_int(event.frame.values, '+quoted(m[1])+')',expression)
    if re.fullmatch(r'!bound_int\(event.frame.shared, "\w+"\)',expression):return expression.replace('bound_int','bound_bool')
    if re.fullmatch(r'bound_int\(event.frame.shared, "\w+"\)',expression):return expression.replace('bound_int','bound_bool')
    if not re.fullmatch(r'[\w\s().,"%!=<>+\-]+',expression):raise ValueError('Unbound parser predicate: '+expression)
    return expression

def parser_bindings(parser,grammar,tokens):
    declarations=exported(parser,'attribute_declarations')
    arguments=exported(parser,'argument_expressions')
    predicates=exported(parser,'parser_predicate_sources')
    actions=exported(parser,'parser_action_sources')
    lines=['  let bindings : @runtime.RuleSemantics = {','    ..@runtime.RuleSemantics::new(),']
    if declarations:
        defaults=[]
        for rule,role,name,kind,initializer in declarations:
            if initializer:raise ValueError('Unbound attribute initializer: '+initializer)
            value='Json::number(0.0)' if kind in {'int','long','float','double'} else 'Json::boolean(false)' if kind=='boolean' else 'Json::null()'
            defaults.append((rule,name,value))
        lines+=['    enter: (rule, frame) => {']
        for rule,name,value in defaults:
            lines.append(f'      if rule == {rule} && !frame.values.contains({quoted(name)}) {{ frame.values[{quoted(name)}] = {value} }}')
        lines+=['      frame','    },','    wrap: (rule, previous) => {','      let values : Map[String, Json] = Map([])']
        for rule,role,name,kind,initializer in declarations:
            if role=='argument':lines.append(f'      if rule == {rule} {{ if previous.values.get({quoted(name)}) is Some(value) {{ values[{quoted(name)}] = value }} }}')
        for rule,name,value in defaults:
            lines.append(f'      if rule == {rule} && !values.contains({quoted(name)}) {{ values[{quoted(name)}] = {value} }}')
        lines+=['      { values, shared: previous.shared.copy(), children: [previous] }','    },']
    if arguments:
        # Every upstream case here passes a single integer argument. The source
        # state, not the callee name, distinguishes repeated calls with new args.
        names={name for _,role,name,_,_ in declarations if role=='argument'}
        if len(names)!=1:raise ValueError('Expected one argument name')
        name=names.pop();lines+=['    arguments: (event, _) => match event.site {']
        for state,expression in arguments:
            expression=expression.strip()
            value=f'bound_int(event.frame.values, {quoted(expression.lstrip("$"))})' if re.fullmatch(r'\$?\w*[A-Za-z_]\w*',expression) else expression
            lines.append(f'      {state} => Map([({quoted(name)}, Json::number(({value}).to_double()))])')
        lines+=['      _ => Map([])','    },']
    if predicates:
        lines+=['    predicate: (event, index) => { ignore(event); match index {']
        for _,index,expression in predicates:
            if 'precpred(' in expression:continue # already executed as ATN precedence edges
            for name,value in re.findall(r'boolean\s+(\w+)\(\s*\)\s*\{\s*return\s+(true|false)\s*;\s*\}',grammar):
                expression=expression.replace('$parser.'+name+'()',value).replace('this.'+name+'()',value)
            lines.append(f'      {index} => {predicate_expression(expression,tokens)}')
        lines+=['      _ => false','    } },']
    effects=[]
    label_states={}
    for label,body in re.findall(r'::label_(\w+)\([^{}]*\{(.*?)\n\}',parser.read_text(encoding='utf8'),re.S):
        match=re.search(r'(?:states=|select_tokens\()\[([^]]*)\]',body)
        if match:label_states.setdefault(label,set()).add(match[1])
    def expression_value(expression,kind):
        accessor='bound_text' if kind=='String' else 'bound_int'
        expression=re.sub(r'\(\(\w+Context\)\$ctx\)\.(\w+)\((\d+)\)\.(\w+)',lambda m:f'{accessor}(bound_rule(event, {quoted(m[1])}, {m[2]}).values, {quoted(m[3])})',expression)
        def attribute(match):
            name,field=match.groups()
            if name in tokens:
                if field=='int':return f'bound_token_int(event, {tokens[name]})'
                if field=='text':return f'bound_token_text(event, {tokens[name]})'
                raise ValueError('Unbound token field: '+field)
            if name in label_states:
                states=label_states[name]
                if len(states)!=1:raise ValueError('Ambiguous label states: '+name)
                frame='bound_label(event, ['+next(iter(states))+'])'
            else:frame=f'bound_rule(event, {quoted(name)}, -1)'
            return f'{accessor}({frame}.values, {quoted(field)})'
        return re.sub(r'\$(\w+)\.(\w+)',attribute,expression)
    for ordinal,body in enumerate(actions):
        statements=[]
        for name,operator,value in re.findall(r'this\.(\w+)\s*(\+=|=)\s*(-?\d+|true|false)\s*;',body):
            if value in {'true','false'}:value=f'Json::boolean({value})'
            else:
                number=f'bound_int(event.frame.shared, {quoted(name)}) + {value}' if operator=='+=' else value
                value=f'Json::number(({number}).to_double())'
            statements.append(f'event.frame.shared[{quoted(name)}] = {value}')
        for name,expression in re.findall(r'\$(\w+)\s*=\s*([^;]+);',body):
            kinds={kind for _,_,field,kind,_ in declarations if field==name}
            if len(kinds)!=1:raise ValueError('Ambiguous attribute type: '+name)
            kind=kinds.pop();expression=expression_value(expression,kind)
            value=f'Json::string({expression})' if kind=='String' else f'Json::number(({expression}).to_double())'
            statements.append(f'event.frame.values[{quoted(name)}] = {value}')
        if statements:effects.append((ordinal,statements))
    if effects:
        lines+=['    action: (event, ordinal) => {','      match ordinal {']
        for ordinal,statements in effects:lines.append(f'        {ordinal} => {{ '+ '; '.join(statements)+' }')
        lines+=['        _ => ()','      }','      event.frame','    },']
    lines+=['  }']
    shared=[]
    for kind,name,value in re.findall(r'\b(int|boolean)\s+(\w+)\s*=\s*(-?\d+|true|false)\s*;',grammar):
        encoded=f'Json::boolean({value})' if kind=='boolean' else f'Json::number(({value}).to_double())'
        shared.append(f'({quoted(name)}, {encoded})')
    return lines,'Map(['+', '.join(shared)+'])'

def instrument_actions(grammar,actions):
    occupied=set();edits=[]
    for ordinal,body in enumerate(actions):
        start=grammar.find(body)
        while start in occupied:start=grammar.find(body,start+1)
        if start<0:raise ValueError('Cannot locate original action body')
        occupied.add(start)
        edits.append((start+1, f'System.err.println("MOON_ACTION:{ordinal}:"+getCurrentToken().getStartIndex());'))
    for offset,text in sorted(edits,reverse=True):grammar=grammar[:offset]+text+grammar[offset:]
    return grammar

def main():
    cli=argparse.ArgumentParser(description=__doc__)
    cli.add_argument('--jar',type=Path,required=True)
    cli.add_argument('--reuse',action='store_true',help='Reuse already compiled private reference artifacts during development')
    cli.add_argument('--java',default=os.environ.get('JAVA','java'))
    cli.add_argument('--javac',default=os.environ.get('JAVAC','javac'))
    args=cli.parse_args();jar=args.jar.resolve()
    if hashlib.sha256(jar.read_bytes()).hexdigest()!=ANTLR_SHA256:cli.error('ANTLR jar checksum mismatch')
    scratch=ROOT/'.local/upstream-reference';scratch.mkdir(parents=True,exist_ok=True)
    plugin=build(jar,ROOT/'.local/moonbit-target.jar',args.javac)
    run([args.javac,'-encoding','UTF-8','-cp',jar,'-d',scratch,ROOT/'tools/UpstreamRenderer.java',ROOT/'tools/UpstreamLexerOracle.java',ROOT/'tools/UpstreamAttributes.java',ROOT/'tools/Oracle.java'])
    paths=sorted(path for group in (ROOT/'conformance/upstream').iterdir() if group.is_dir() for path in group.glob('*.txt'))
    if dict(Counter(path.parent.name for path in paths))!=EXPECTED_CATEGORIES:
        cli.error('Pinned functional descriptor inventory differs from the 350-case corpus')
    def process(pair):
        index,path=pair;data=sections(path);key=path.parent.name.lower()+'_'+path.stem.lower();directory=scratch/key;directory.mkdir(exist_ok=True)
        name=re.search(r'\bgrammar\s+(\w+)\s*;',data['grammar']).group(1)
        grammar=directory/(name+'.g4')
        package=package_key(key)
        generated=ROOT/'generated/upstream'/package
        native_parser=generated/(name+'Parser.mbt')
        class_file=directory/((name if data['type']=='Lexer' else name+'Parser')+'.class')
        if args.reuse and class_file.exists() and (generated/'moon.pkg').exists():
            original=re.sub(r'System\.err\.println\("MOON_ACTION:\d+:"\+getCurrentToken\(\)\.getStartIndex\(\)\);','',grammar.read_text(encoding='utf8'))
        else:
            raw=directory/'template.g4';raw.write_text(data['grammar'],encoding='utf8')
            name=re.search(r'\bgrammar\s+(\w+)\s*;',data['grammar']).group(1)
            grammar=directory/(name+'.g4')
            run([args.java,'-cp',str(scratch)+os.pathsep+str(jar),'UpstreamRenderer',ROOT/'conformance/upstream/Java.test.stg',raw,grammar])
            slaves=[]
            for i,body in enumerate(data.get('slaveGrammar',[])):
                slave_name=re.search(r'\bgrammar\s+(\w+)\s*;',body).group(1)
                slave_raw=directory/f'slave{i}.template';slave_raw.write_text(body,encoding='utf8')
                slave=directory/(slave_name+'.g4')
                run([args.java,'-cp',str(scratch)+os.pathsep+str(jar),'UpstreamRenderer',ROOT/'conformance/upstream/Java.test.stg',slave_raw,slave])
                slaves.append(slave)
            generated=ROOT/'generated/upstream'/package;generated.mkdir(parents=True,exist_ok=True)
            run([args.java,'-cp',str(plugin)+os.pathsep+str(jar),'org.antlr.v4.Tool','-Dlanguage=MoonBit','-encoding','UTF-8','-Xexact-output-dir','-lib',directory,'-o',generated,grammar])
            original=grammar.read_text(encoding='utf8')
            if data['type']=='Parser':
                native_parser=generated/(name+'Parser.mbt')
                combined=[grammar]+slaves
                original_sources=[source.read_text(encoding='utf8') for source in combined]
                marked=instrument_actions('\nMOON_FILE_BOUNDARY\n'.join(original_sources),exported(native_parser,'parser_action_sources')).split('\nMOON_FILE_BOUNDARY\n')
                for source,body in zip(combined,marked):source.write_text(body,encoding='utf8')
            run([args.java,'-jar',jar,'-encoding','UTF-8','-Xexact-output-dir','-lib',directory,'-o',directory,grammar])
            run([args.javac,'-encoding','UTF-8','-cp',str(scratch)+os.pathsep+str(jar),'-d',directory]+sorted(directory.glob('*.java')))
        payload=base64.b64encode(data['input'].encode()).decode()+'\n'
        classpath=str(directory)+os.pathsep+str(scratch)+os.pathsep+str(jar)
        lexer_name=name if data['type']=='Lexer' else name+'Lexer'
        lex=run([args.java,'-Dfile.encoding=UTF-8','-cp',classpath,'UpstreamLexerOracle',lexer_name],input=payload)
        lex=json.loads(lex.stdout[lex.stdout.rfind('{"tokens":'):])
        out=['///|',f'test "upstream {path.parent.name} {path.stem}" {{']
        alias=f'@u{index:03d}'
        if data['type']=='Lexer':
            extra=', lexer_action=(_, _) => ()'
            if path.parent.name=='SemPredEvalLexer':
                sources=re.findall(r'\{([^{}]*)\}\s*\?',grammar.read_text(encoding='utf8'))
                expressions=[]
                for expression in sources:
                    expression=expression.strip()
                    if expression in {'true','false'}:moon=expression
                    elif 'getText().equals(' in expression:
                        value=re.search(r'equals\((".*?")\)',expression).group(1);moon='event.text == '+value
                    elif '_tokenStartCharPositionInLine' in expression:moon=expression.replace('this._tokenStartCharPositionInLine','event.token_column')
                    elif 'getCharPositionInLine()' in expression:moon=expression.replace('this.getCharPositionInLine()','event.column')
                    else:raise ValueError('Unbound upstream Lexer predicate: '+expression)
                    expressions.append(moon)
                out += ['  let predicate : @runtime.LexerContextPredicate = event => match event.predicate {']
                out += [f'    {i} => {expression}' for i,expression in enumerate(expressions)]
                out += ['    _ => false','  }']
                extra=', lexer_context_predicate=predicate, lexer_action=(_, _) => ()'
            if path.stem=='PositionAdjustingLexer':
                out += [f'  let lexed = position_adjusted_tokens({alias}.lexer_data(), {quoted(data["input"])}, 4, 5)']
            else:
                out += [f'  let lexed = @runtime.deserialize({alias}.lexer_data()).tokenize_recovering({quoted(data["input"])}{extra})']
        else:
            declarations=exported(native_parser,'attribute_declarations')
            specification=','.join(str(rule)+':'+field for rule,_,field,_,_ in declarations)
            reference=run([args.java,'-Dfile.encoding=UTF-8','-Dmoonantlr.attributes='+specification,'-cp',classpath,'Oracle',name,data['start'],'default'],input=payload)
            row=json.loads(reference.stdout[reference.stdout.rfind('{"tree":'):])
            rules=read_interp(directory/(name+'.interp'))[1];start=rules.index(data['start'])
            positions=', '.join(f'(Some({line}), Some({col}))' for line,col in row['parserErrors'])
            tokens=dict((name,int(value)) for name,value in re.findall(r'^(\w+)=(\d+)$',(directory/(name+'.tokens')).read_text(),re.M))
            bindings,shared=parser_bindings(native_parser,original,tokens)
            trace=[(int(ordinal),int(offset)) for ordinal,offset in re.findall(r'MOON_ACTION:(\d+):(\d+)',reference.stderr)]
            out += bindings
            out += ['  let actions : Array[(Int,Int)] = []',f'  let grammar = {alias}.grammar()',f'  let parsed = grammar.parse_default({quoted(data["input"])}, start_rule={start}, semantics=bindings, shared={shared}, lexer_action=(_, _) => (), parser_action=event => actions.push((event.action,event.next_token.start)))',
                f'  @debug.assert_eq(actions, [{tuples(trace)}])',
                f'  assert_eq(parsed.tree.to_sexpr(), {quoted(row["tree"])})',f'  @debug.assert_eq(parsed.diagnostics.map(d => (d.line, d.column)), [{positions}])',
                f'  @debug.assert_eq(parsed.tree.error_tokens().map(t => (t.kind,t.text,t.start,t.end,t.line,t.column,t.channel)), [{tuples(row["errorTokens"])}])',
                f'  assert_eq(parsed.next_token.kind, {row["nextKind"]})',f'  assert_eq(parsed.next_token.text, {quoted(row["nextText"])})',
                f'  let lexed = grammar.tokenize_recovering({quoted(data["input"])}, lexer_action=(_, _) => ())']
            out += [f'  assert_eq(bound_frame_json(parsed.frame.unwrap()), @json.parse({quoted(json.dumps(row["frame"],ensure_ascii=False,separators=(",",":")))}))']
            out += [f'  @debug.assert_eq(bound_listener_events(parsed.tree), {quoted(row["events"])})']
            for field,value in row['shared'].items():
                out += [f'  assert_eq(parsed.frame.unwrap().shared.get({quoted(field)}), Some(@json.parse({quoted(json.dumps(value,ensure_ascii=False))})))']
        positions=', '.join(f'({line}, {col})' for line,col in lex['errors'])
        out += [f'  @debug.assert_eq(lexed.tokens.map(t => (t.kind,t.text,t.start,t.end,t.line,t.column,t.channel)), [{tuples(lex["tokens"])}])',
            f'  @debug.assert_eq(lexed.errors.map(e => match e {{ @runtime.LexicalError(line,col,_) => (line,col); _ => (-1,-1) }}), [{positions}])','}','']
        return index,package,out,{'group':path.parent.name,'name':path.stem,'descriptor_sha256':hashlib.sha256(path.read_text(encoding="utf8").encode("utf8")).hexdigest(),'mode':'Java tokens, trees, diagnostics, actions and attribute frames'}
    rows=[];failures=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        pending={pool.submit(process,pair):pair[1] for pair in enumerate(paths)}
        for future in concurrent.futures.as_completed(pending):
            path=pending[future]
            try:
                result=future.result();rows.append(result);print('Upstream:',result[3]['group'],result[3]['name'],flush=True)
            except Exception as error:
                if isinstance(error,subprocess.CalledProcessError):reason=error.stderr or str(error)
                else:reason=str(error)
                failures.append({'group':path.parent.name,'name':path.stem,'error':reason})
                print('Upstream generation failure:',path.parent.name,path.stem,reason[:180],flush=True)
    rows.sort()
    (scratch/'failures.json').write_text(json.dumps(failures,indent=2)+'\n',encoding='utf8')
    imports=['  "moonbitlang/core/json",','  "wdgodghl/moonantlr" @runtime,','  "moonbitlang/core/debug",']
    output=['// Generated from pinned ANTLR 4.13.2 upstream runtime descriptors.','']
    for index,key,lines,entry in sorted(rows):
        imports.append(f'  "wdgodghl/moonantlr/generated/upstream/{key}" @u{index:03d},')
        output.extend(lines)
    (ROOT/'conformance/moon.pkg').write_text('import {\n'+'\n'.join(imports)+'\n} for "test"\n',encoding='utf8',newline='\n')
    (ROOT/'conformance/oracle_test.mbt').write_text('\n'.join(output),encoding='utf8',newline='\n')
    manifest={'upstream':'antlr/antlr4','version':'4.13.2','cases':[row[3] for row in rows],'failures':failures}
    (ROOT/'conformance/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf8',newline='\n')
    print('Upstream structural comparisons:',len(rows),'failures:',len(failures))
    if failures:raise SystemExit(1)
if __name__=='__main__':main()
