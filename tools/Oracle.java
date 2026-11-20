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
        String rule = args.length > 1 ? args[1] : "document";
        BufferedReader input = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8));
        String line;
        while ((line = input.readLine()) != null) {
            String source = new String(Base64.getDecoder().decode(line), StandardCharsets.UTF_8);
            int[] errors = {0};
            java.util.List<String> lexerErrors = new java.util.ArrayList<>();
            java.util.List<String> parserErrors = new java.util.ArrayList<>();
            java.util.List<String> allErrors = new java.util.ArrayList<>();
            BaseErrorListener listener = new BaseErrorListener() {
                @Override public void syntaxError(Recognizer<?, ?> r, Object symbol, int row, int column, String message, RecognitionException e) {
                    errors[0]++;
                    allErrors.add("[" + row + "," + column + "]");
                    if (r instanceof Lexer) lexerErrors.add("[" + row + "," + column + "]");
                    else parserErrors.add("[" + row + "," + column + "]");
                }
            };
            Lexer lexer = (Lexer) Class.forName(grammar + "Lexer").getConstructor(CharStream.class).newInstance(CharStreams.fromString(source));
            lexer.removeErrorListeners();
            lexer.addErrorListener(listener);
            CommonTokenStream stream = new CommonTokenStream(lexer);
            if (args.length < 3) stream.fill();
            Parser parser = (Parser) Class.forName(grammar + "Parser").getConstructor(TokenStream.class).newInstance(stream);
            parser.removeErrorListeners();
            parser.addErrorListener(listener);
            ParseTree parsed = (ParseTree) parser.getClass().getMethod(rule).invoke(parser);
            boolean accepted = errors[0] == 0 && (args.length > 1 || parser.getCurrentToken().getType() == Token.EOF);
            StringBuilder out = new StringBuilder("{\"accepted\":").append(accepted).append(",\"tree\":").append(quote(tree(parsed, parser), false)).append(",\"tokens\":[");
            Token next = parser.getCurrentToken();
            if (args.length > 2 && args[2].equals("default")) {
                Object offsets = grammar.equals("ParseActions") ? parser.getClass().getField("offsets").get(parser) : "[]";
                java.util.List<String> errorTokens = new java.util.ArrayList<>();
                errorTokens(parsed, errorTokens);
                java.util.List<String> events = new java.util.ArrayList<>();
                ParseTreeWalker.DEFAULT.walk(new ParseTreeListener() {
                    public void enterEveryRule(ParserRuleContext ctx) { events.add(quote("enter:" + parser.getRuleNames()[ctx.getRuleIndex()],false)); }
                    public void exitEveryRule(ParserRuleContext ctx) { events.add(quote("exit:" + parser.getRuleNames()[ctx.getRuleIndex()],false)); }
                    public void visitTerminal(TerminalNode node) { events.add(quote("token:" + node.getText(),false)); }
                    public void visitErrorNode(ErrorNode node) { events.add(quote("error:" + node.getText(),false)); }
                }, parsed);
                System.out.println("{\"tree\":" + quote(errorTree(parsed, parser), false)
                    + ",\"parserErrors\":[" + String.join(",", allErrors)
                    + "],\"events\":[" + String.join(",", events) + "],\"errorTokens\":[" + String.join(",", errorTokens) + "],\"offsets\":" + offsets + ",\"nextKind\":" + next.getType() + ",\"nextText\":" + quote(next.getText(), false) + "}");
                continue;
            }
            boolean first = true;
            for (Token t : stream.getTokens()) {
                if (!first) out.append(',');
                first = false;
                out.append('[').append(t.getType()).append(',').append(quote(t.getText(), false))
                   .append(',').append(t.getStartIndex()).append(',').append(t.getStopIndex() + 1)
                   .append(',').append(t.getLine()).append(',').append(t.getCharPositionInLine())
                   .append(',').append(t.getChannel()).append(']');
            }
            if (grammar.equals("Attributes")) {
                Object total = parsed.getClass().getField("total").get(parsed);
                System.out.println(out.append("],\"total\":").append(total).append('}'));
                continue;
            }
            if (grammar.equals("ParseActions")) {
                Object offsets = parser.getClass().getField("offsets").get(parser);
                System.out.println(out.append("],\"offsets\":").append(offsets).append('}'));
                continue;
            }
            if (grammar.equals("LexActions")) {
                @SuppressWarnings("unchecked")
                java.util.List<Integer> offsets = (java.util.List<Integer>) lexer.getClass().getField("offsets").get(lexer);
                out.append("],\"lexerErrors\":[").append(String.join(",", lexerErrors))
                   .append("],\"offsets\":").append(offsets).append('}');
                System.out.println(out);
                continue;
            }
            System.out.println(out.append("],\"nextKind\":").append(next.getType()).append(",\"nextText\":").append(quote(next.getText(), false)).append('}').toString());
        }
    }

    private static String errorTree(ParseTree node, Parser parser) {
        if (node instanceof ErrorNode) return "(error " + quote(node.getText(), true) + ")";
        if (node instanceof TerminalNode) {
            Token token = ((TerminalNode) node).getSymbol();
            return token.getType() == Token.EOF ? "<EOF>" : quote(token.getText(), true);
        }
        ParserRuleContext rule = (ParserRuleContext) node;
        StringBuilder out = new StringBuilder("(").append(parser.getRuleNames()[rule.getRuleIndex()]);
        for (int i = 0; i < rule.getChildCount(); i++) out.append(' ').append(errorTree(rule.getChild(i), parser));
        return out.append(')').toString();
    }

    private static void errorTokens(ParseTree node, java.util.List<String> tokens) {
        if (node instanceof ErrorNode) {
            Token t = ((ErrorNode) node).getSymbol();
            tokens.add("[" + t.getType() + "," + quote(t.getText(),false) + "," + t.getStartIndex()
                + "," + (t.getStopIndex()+1) + "," + t.getLine() + "," + t.getCharPositionInLine() + "," + t.getChannel() + "]");
        }
        for (int i = 0; i < node.getChildCount(); i++) errorTokens(node.getChild(i), tokens);
    }
}
