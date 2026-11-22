import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;

/** Independent runtime callbacks, not inferred from the eventual parse tree. */
public final class PredictionTrace extends DiagnosticErrorListener {
    public final List<String> events=new ArrayList<>();
    private final boolean diagnostics;
    public PredictionTrace(boolean diagnostics) { super(true); this.diagnostics=diagnostics; }
    private void record(Parser parser,String kind,DFA dfa,int start,int stop,boolean exact,BitSet alts,int prediction) {
        List<String> alternatives=new ArrayList<>();
        if(alts!=null) for(int i=alts.nextSetBit(0);i>=0;i=alts.nextSetBit(i+1)) alternatives.add(Integer.toString(i));
        events.add("{\"kind\":"+UpstreamAttributes.q(kind)+",\"decision\":"+dfa.decision+
            ",\"start\":"+parser.getTokenStream().get(start).getStartIndex()+
            ",\"stop\":"+parser.getTokenStream().get(stop).getStartIndex()+
            ",\"exact\":"+exact+",\"alternatives\":["+String.join(",",alternatives)+"],\"prediction\":"+prediction+"}");
    }
    @Override public void reportAttemptingFullContext(Parser p,DFA d,int a,int b,BitSet alts,ATNConfigSet configs) {
        record(p,"attempting_full_context",d,a,b,false,alts,0);
        if(diagnostics)super.reportAttemptingFullContext(p,d,a,b,alts,configs);
    }
    @Override public void reportAmbiguity(Parser p,DFA d,int a,int b,boolean exact,BitSet alts,ATNConfigSet configs) {
        record(p,"ambiguity",d,a,b,exact,alts==null?configs.getAlts():alts,0);
        if(diagnostics)super.reportAmbiguity(p,d,a,b,exact,alts,configs);
    }
    @Override public void reportContextSensitivity(Parser p,DFA d,int a,int b,int prediction,ATNConfigSet configs) {
        record(p,"context_sensitivity",d,a,b,false,null,prediction);
        if(diagnostics)super.reportContextSensitivity(p,d,a,b,prediction,configs);
    }
}
