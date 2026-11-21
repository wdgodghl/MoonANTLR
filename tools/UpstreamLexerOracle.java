import java.io.*;
import java.util.*;
import java.nio.charset.StandardCharsets;
import org.antlr.v4.runtime.*;

/** Record all Token metadata and diagnostic positions, independently of MoonBit. */
public final class UpstreamLexerOracle {
    static String q(String value) {
        StringBuilder out=new StringBuilder("\"");
        for(char c:value.toCharArray()) {
            switch(c) {
                case '"':out.append("\\\"");break;
                case '\\':out.append("\\\\");break;
                case '\n':out.append("\\n");break;
                case '\r':out.append("\\r");break;
                case '\t':out.append("\\t");break;
                default: if(c<32) out.append(String.format("\\u%04x",(int)c));else out.append(c);
            }
        }
        return out.append('"').toString();
    }
    public static void main(String[] args) throws Exception {
        BufferedReader reader=new BufferedReader(new InputStreamReader(System.in,StandardCharsets.UTF_8));
        String source=new String(Base64.getDecoder().decode(reader.readLine()),StandardCharsets.UTF_8);
        Lexer lexer=(Lexer)Class.forName(args[0]).getConstructor(CharStream.class).newInstance(CharStreams.fromString(source));
        List<String> errors=new ArrayList<>(); lexer.removeErrorListeners();
        lexer.addErrorListener(new BaseErrorListener(){
            public void syntaxError(Recognizer<?,?> r,Object sym,int line,int col,String msg,RecognitionException e){errors.add("["+line+","+col+"]");}
        });
        List<String> tokens=new ArrayList<>();
        for(;;){Token t=lexer.nextToken(); tokens.add("["+t.getType()+","+q(t.getText())+","+t.getStartIndex()+","+(t.getStopIndex()+1)+","+t.getLine()+","+t.getCharPositionInLine()+","+t.getChannel()+"]");if(t.getType()==Token.EOF)break;}
        System.out.println("{\"tokens\":["+String.join(",",tokens)+"],\"errors\":["+String.join(",",errors)+"]}");
    }
}
