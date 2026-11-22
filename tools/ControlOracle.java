import java.lang.reflect.InvocationTargetException;
import org.antlr.v4.runtime.*;

/** Boundary and runtime-control observations from real generated Java. */
public final class ControlOracle {
    static String boundaries(ParserRuleContext context, Parser parser) {
        StringBuilder out=new StringBuilder(parser.getRuleNames()[context.getRuleIndex()]);
        out.append(':').append(context.start==null?-1:context.start.getStartIndex());
        out.append(':').append(context.stop==null?-1:context.stop.getStartIndex());
        out.append(':').append(context.getChildCount());
        for(int i=0;i<context.getChildCount();i++) if(context.getChild(i) instanceof ParserRuleContext)
            out.append('|').append(boundaries((ParserRuleContext)context.getChild(i),parser));
        return out.toString();
    }
    public static void main(String[] args) throws Exception {
        ControlLexer lexer=new ControlLexer(CharStreams.fromString(args[1]));
        CommonTokenStream stream=new CommonTokenStream(lexer);
        ControlParser parser=new ControlParser(stream);
        parser.removeErrorListeners();
        try {
            ParserRuleContext result=(ParserRuleContext)parser.getClass().getMethod(args[0]).invoke(parser);
            System.out.println("{\"tree\":"+UpstreamAttributes.q(Oracle.errorTree(result,parser))+",\"boundaries\":"+UpstreamAttributes.q(boundaries(result,parser))+",\"error\":\"\"}");
        } catch(InvocationTargetException failure) {
            Throwable cause=failure.getCause().getCause();
            RecognitionException error=(RecognitionException)cause;
            Token token=error.getOffendingToken();
            System.out.println("{\"error\":"+UpstreamAttributes.q(error.getClass().getSimpleName())+",\"line\":"+token.getLine()+",\"column\":"+token.getCharPositionInLine()+"}");
        }
    }
}
