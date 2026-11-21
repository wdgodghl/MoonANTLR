// Independent snapshots after original grammars-v4 host helper calls.
import org.antlr.v4.runtime.*;
import java.util.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.lang.reflect.Field;

public class CSharpTraceOracle {
    static String q(String text) { return CSharpOracle.quote(text,false); }
    static <T> List<T> bottomFirst(Deque<T> stack) { List<T> result=new ArrayList<>(stack); Collections.reverse(result); return result; }
    static class TraceLexer extends CSharpLexer {
        final List<String> events=new ArrayList<>();
        TraceLexer(CharStream source) { super(source); removeErrorListeners(); }
        void record(String name) {
            events.add("{\"method\":"+q(name)+",\"offset\":"+getCharIndex()+",\"strings\":"+bottomFirst(interpolatedVerbatiums)
                +",\"braces\":"+bottomFirst(curlyLevels)+",\"mode\":"+_mode+"}");
        }
        @Override protected void OnInterpolatedRegularStringStart() { super.OnInterpolatedRegularStringStart(); record("OnInterpolatedRegularStringStart"); }
        @Override protected void OnInterpolatedVerbatiumStringStart() { super.OnInterpolatedVerbatiumStringStart(); record("OnInterpolatedVerbatiumStringStart"); }
        @Override protected void OnOpenBrace() { super.OnOpenBrace(); record("OnOpenBrace"); }
        @Override protected void OnCloseBrace() { super.OnCloseBrace(); record("OnCloseBrace"); }
        @Override protected void OnColon() { super.OnColon(); record("OnColon"); }
        @Override protected void OpenBraceInside() { super.OpenBraceInside(); record("OpenBraceInside"); }
        @Override protected void OnDoubleQuoteInside() { super.OnDoubleQuoteInside(); record("OnDoubleQuoteInside"); }
        @Override protected void OnCloseBraceInside() { super.OnCloseBraceInside(); record("OnCloseBraceInside"); }
    }
    static class TraceParser extends CSharpPreprocessorParser {
        final List<String> events=new ArrayList<>();
        TraceParser(TokenStream source) { super(source); removeErrorListeners(); }
        void record(String name) {
            try {
                Field field=CSharpPreprocessorParserBase.class.getDeclaredField("conditions"); field.setAccessible(true);
                @SuppressWarnings("unchecked") Deque<Boolean> conditions=(Deque<Boolean>)field.get(this);
                Object value=_ctx.getClass().getField("value").get(_ctx);
                List<String> symbols=new ArrayList<>(ConditionalSymbols); Collections.sort(symbols);
                List<String> quoted=new ArrayList<>(); for(String symbol:symbols) quoted.add(q(symbol));
                events.add("{\"method\":"+q(name)+",\"offset\":"+getCurrentToken().getStartIndex()
                    +",\"value\":"+(value instanceof String?q((String)value):String.valueOf(value))
                    +",\"conditions\":"+bottomFirst(conditions)+",\"symbols\":["+String.join(",",quoted)+"]}");
            } catch(ReflectiveOperationException e) { throw new IllegalStateException(e); }
        }
        @Override protected void OnPreprocessorDirectiveDefine() { super.OnPreprocessorDirectiveDefine(); record("OnPreprocessorDirectiveDefine"); }
        @Override protected void OnPreprocessorDirectiveUndef() { super.OnPreprocessorDirectiveUndef(); record("OnPreprocessorDirectiveUndef"); }
        @Override protected void OnPreprocessorDirectiveIf() { super.OnPreprocessorDirectiveIf(); record("OnPreprocessorDirectiveIf"); }
        @Override protected void OnPreprocessorDirectiveElif() { super.OnPreprocessorDirectiveElif(); record("OnPreprocessorDirectiveElif"); }
        @Override protected void OnPreprocessorDirectiveElse() { super.OnPreprocessorDirectiveElse(); record("OnPreprocessorDirectiveElse"); }
        @Override protected void OnPreprocessorDirectiveEndif() { super.OnPreprocessorDirectiveEndif(); record("OnPreprocessorDirectiveEndif"); }
        @Override protected void OnPreprocessorDirectiveLine() { super.OnPreprocessorDirectiveLine(); record("OnPreprocessorDirectiveLine"); }
        @Override protected void OnPreprocessorDirectiveError() { super.OnPreprocessorDirectiveError(); record("OnPreprocessorDirectiveError"); }
        @Override protected void OnPreprocessorDirectiveWarning() { super.OnPreprocessorDirectiveWarning(); record("OnPreprocessorDirectiveWarning"); }
        @Override protected void OnPreprocessorDirectiveRegion() { super.OnPreprocessorDirectiveRegion(); record("OnPreprocessorDirectiveRegion"); }
        @Override protected void OnPreprocessorDirectiveEndregion() { super.OnPreprocessorDirectiveEndregion(); record("OnPreprocessorDirectiveEndregion"); }
        @Override protected void OnPreprocessorDirectivePragma() { super.OnPreprocessorDirectivePragma(); record("OnPreprocessorDirectivePragma"); }
        @Override protected void OnPreprocessorDirectiveNullable() { super.OnPreprocessorDirectiveNullable(); record("OnPreprocessorDirectiveNullable"); }
        @Override protected void OnPreprocessorExpressionTrue() { super.OnPreprocessorExpressionTrue(); record("OnPreprocessorExpressionTrue"); }
        @Override protected void OnPreprocessorExpressionFalse() { super.OnPreprocessorExpressionFalse(); record("OnPreprocessorExpressionFalse"); }
        @Override protected void OnPreprocessorExpressionConditionalSymbol() { super.OnPreprocessorExpressionConditionalSymbol(); record("OnPreprocessorExpressionConditionalSymbol"); }
        @Override protected void OnPreprocessorExpressionConditionalOpenParens() { super.OnPreprocessorExpressionConditionalOpenParens(); record("OnPreprocessorExpressionConditionalOpenParens"); }
        @Override protected void OnPreprocessorExpressionConditionalBang() { super.OnPreprocessorExpressionConditionalBang(); record("OnPreprocessorExpressionConditionalBang"); }
        @Override protected void OnPreprocessorExpressionConditionalEq() { super.OnPreprocessorExpressionConditionalEq(); record("OnPreprocessorExpressionConditionalEq"); }
        @Override protected void OnPreprocessorExpressionConditionalNe() { super.OnPreprocessorExpressionConditionalNe(); record("OnPreprocessorExpressionConditionalNe"); }
        @Override protected void OnPreprocessorExpressionConditionalAnd() { super.OnPreprocessorExpressionConditionalAnd(); record("OnPreprocessorExpressionConditionalAnd"); }
        @Override protected void OnPreprocessorExpressionConditionalOr() { super.OnPreprocessorExpressionConditionalOr(); record("OnPreprocessorExpressionConditionalOr"); }
    }
    public static void main(String[] args) throws Exception {
        BufferedReader reader=new BufferedReader(new InputStreamReader(System.in,StandardCharsets.UTF_8));
        String line;
        while((line=reader.readLine())!=null) {
            String[] parts=line.split(" ",2); String source=new String(Base64.getDecoder().decode(parts[1]),StandardCharsets.UTF_8);
            TraceLexer lexer=new TraceLexer(CharStreams.fromString(source));
            CommonTokenStream stream=new CommonTokenStream(lexer,CSharpLexer.DIRECTIVE); stream.fill();
            List<String> parserEvents=new ArrayList<>();
            if(parts[0].equals("directives")) {
                TraceParser parser=new TraceParser(stream);
                while(parser.getCurrentToken().getType()!=Token.EOF) {
                    int before=stream.index(); parser.preprocessor_directive();
                    if(before==stream.index()) throw new IllegalStateException("no directive progress");
                }
                parserEvents=parser.events;
            }
            System.out.println("{\"lexer\":["+String.join(",",lexer.events)+"],\"preprocessor\":["+String.join(",",parserEvents)+"]}");
        }
    }
}
