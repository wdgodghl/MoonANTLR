import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

/** Independent ANTLR Java-target oracle. Generated Java stays in .local/. */
public final class Oracle {
    private static String quote(String text, boolean moon) {
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
        String grammar = args[0];
        BufferedReader input = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8));
        String line;
        while ((line = input.readLine()) != null) {
            String source = new String(Base64.getDecoder().decode(line), StandardCharsets.UTF_8);
            int[] errors = {0};
            BaseErrorListener listener = new BaseErrorListener() {
                @Override public void syntaxError(Recognizer<?, ?> r, Object symbol, int row, int column, String message, RecognitionException e) {
                    errors[0]++;
                }
            };
            Lexer lexer = (Lexer) Class.forName(grammar + "Lexer").getConstructor(CharStream.class).newInstance(CharStreams.fromString(source));
            lexer.removeErrorListeners();
            lexer.addErrorListener(listener);
            CommonTokenStream stream = new CommonTokenStream(lexer);
            stream.fill();
            Parser parser = (Parser) Class.forName(grammar + "Parser").getConstructor(TokenStream.class).newInstance(stream);
            parser.removeErrorListeners();
            parser.addErrorListener(listener);
            ParseTree parsed = (ParseTree) parser.getClass().getMethod("document").invoke(parser);
            boolean accepted = errors[0] == 0 && parser.getCurrentToken().getType() == Token.EOF;
            StringBuilder out = new StringBuilder("{\"accepted\":").append(accepted).append(",\"tree\":").append(quote(tree(parsed, parser), false)).append(",\"tokens\":[");
            boolean first = true;
            for (Token t : stream.getTokens()) {
                if (!first) out.append(',');
                first = false;
                out.append('[').append(t.getType()).append(',').append(quote(t.getText(), false))
                   .append(',').append(t.getStartIndex()).append(',').append(t.getStopIndex() + 1)
                   .append(',').append(t.getLine()).append(',').append(t.getCharPositionInLine())
                   .append(',').append(t.getChannel()).append(']');
            }
            System.out.println(out.append("]}").toString());
        }
    }
}
