import java.lang.reflect.InvocationTargetException;
import java.util.*;
import org.antlr.v4.runtime.*;

/** Execute real generated Java try/catch/finally boundaries, including unwind. */
public final class LifecycleExceptionOracle {
    public static void main(String[] args) throws Exception {
        Lexer lexer=(Lexer)Class.forName(args[0]+"Lexer").getConstructor(CharStream.class).newInstance(CharStreams.fromString(args[3]));
        Parser parser=(Parser)Class.forName(args[0]+"Parser").getConstructor(TokenStream.class).newInstance(new CommonTokenStream(lexer));
        parser.getClass().getField("failStages").set(parser,args[2]);
        String failure="";
        String tree="";
        int captures=-1;
        try {
            org.antlr.v4.runtime.tree.ParseTree parsed=(org.antlr.v4.runtime.tree.ParseTree)parser.getClass().getMethod(args[1]).invoke(parser);
            tree=Oracle.errorTree(parsed,parser);
            try { captures=parsed.getClass().getField("child").get(parsed)==null?0:1; } catch(NoSuchFieldException ignored) { }
        }
        catch(InvocationTargetException error) { failure=error.getCause().getMessage(); }
        List<String> events=new ArrayList<>();
        @SuppressWarnings("unchecked") List<String> visits=(List<String>)parser.getClass().getField("visits").get(parser);
        for(String stage:visits)events.add(UpstreamAttributes.q(stage));
        System.out.println("{\"events\":["+String.join(",",events)+"],\"error\":"+UpstreamAttributes.q(failure)+",\"diagnostics\":"+parser.getNumberOfSyntaxErrors()+",\"tree\":"+UpstreamAttributes.q(tree)+",\"totals\":"+parser.getClass().getField("totals").get(parser)+",\"finalCounts\":"+parser.getClass().getField("finalCounts").get(parser)+",\"captures\":"+captures+"}");
    }
}
