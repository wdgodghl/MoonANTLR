import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

public class CSharpOracle {
    static String quote(String text, boolean moon) {
        StringBuilder out = new StringBuilder("\"");
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '"': out.append("\\\""); break;
                case '\\': out.append("\\\\"); break;
                case '\n': out.append("\\n"); break;
                case '\r': out.append("\\r"); break;
                case '\t': out.append("\\t"); break;
                case '\b': out.append("\\b"); break;
                default:
                    if (c < 32) {
                        if (moon) out.append("\\u{").append(Integer.toHexString(c)).append('}');
                        else out.append(String.format("\\u%04x", (int) c));
                    } else out.append(c);
            }
        }
        return out.append('"').toString();
    }

    private static String tree(ParseTree node, Parser parser) {
        if (node instanceof ErrorNode) return "(error " + quote(node.getText(),true) + ")";
        if (node instanceof TerminalNode) {
            Token t = ((TerminalNode) node).getSymbol();
            return t.getType() == Token.EOF ? "<EOF>" : quote(t.getText(), true);
        }
        ParserRuleContext rule = (ParserRuleContext) node;
        StringBuilder out = new StringBuilder("(").append(parser.getRuleNames()[rule.getRuleIndex()]);
        for (int i = 0; i < rule.getChildCount(); i++) out.append(' ').append(tree(rule.getChild(i), parser));
        return out.append(')').toString();
    }


    public static void main(String[] args) throws Exception {
        BufferedReader input = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8));
        String line;
        while ((line = input.readLine()) != null) {
            String[] parts = line.split(" ", 2);
            String rule = parts[0];
            String source = new String(Base64.getDecoder().decode(parts[1]), StandardCharsets.UTF_8);
            int[] errors = {0};
            List<String> positions = new ArrayList<>();
            BaseErrorListener listener = new BaseErrorListener() {
                public void syntaxError(Recognizer<?,?> r, Object sym, int row, int col, String msg, RecognitionException e) {
                    errors[0]++; positions.add("[" + row + "," + col + "]");
                }
            };
            CSharpLexer lexer = new CSharpLexer(CharStreams.fromString(source));
            lexer.removeErrorListeners();
            lexer.addErrorListener(listener);
            CommonTokenStream stream = new CommonTokenStream(lexer, rule.equals("directives") ? CSharpLexer.DIRECTIVE : Token.DEFAULT_CHANNEL);
            stream.fill();
            List<Boolean> values = new ArrayList<>();
            String parsed = "";
            if (rule.equals("directives")) {
                CSharpPreprocessorParser parser = new CSharpPreprocessorParser(stream);
                parser.removeErrorListeners(); parser.addErrorListener(listener);
                while (parser.getCurrentToken().getType() != Token.EOF) {
                    int index = stream.index();
                    values.add(parser.preprocessor_directive().value);
                    if (stream.index() == index) throw new IllegalStateException("no progress");
                }
            } else if (!rule.equals("tokens")) {
                CSharpParser parser = new CSharpParser(stream);
                parser.removeErrorListeners(); parser.addErrorListener(listener);
                ParseTree result = (ParseTree)parser.getClass().getMethod(rule).invoke(parser);
                parsed = tree(result, parser);
                if (parser.getCurrentToken().getType() != Token.EOF) errors[0]++;
            }
            StringBuilder out = new StringBuilder("{\"accepted\":").append(errors[0] == 0)
                .append(",\"tree\":").append(quote(parsed,false)).append(",\"errors\":[").append(String.join(",", positions))
                .append("],\"values\":").append(values).append(",\"tokens\":[");
            boolean first = true;
            for (Token token : stream.getTokens()) {
                if (!first) out.append(','); first = false;
                out.append('[').append(token.getType()).append(',').append(quote(token.getText(),false))
                   .append(',').append(token.getStartIndex()).append(',').append(token.getStopIndex()+1)
                   .append(',').append(token.getLine()).append(',').append(token.getCharPositionInLine())
                   .append(',').append(token.getChannel()).append(']');
            }
            System.out.println(out.append("]}"));
        }
    }
}
