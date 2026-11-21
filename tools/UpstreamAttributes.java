import java.lang.reflect.*;
import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

/** Independent snapshots of declared rule attributes and Parser member state. */
public final class UpstreamAttributes {
    static String q(String value) {
        StringBuilder out=new StringBuilder("\"");
        for(char c:value.toCharArray()) {
            switch(c) {
                case '"':out.append("\\\"");break;
                case '\\':out.append("\\\\");break;
                case '\n':out.append("\\n");break;
                case '\r':out.append("\\r");break;
                case '\t':out.append("\\t");break;
                default:if(c<32)out.append(String.format("\\u%04x",(int)c));else out.append(c);
            }
        }
        return out.append('"').toString();
    }
    static String value(Object value) { return value instanceof String?q((String)value):String.valueOf(value); }
    static String fields(Map<String,Object> values) {
        List<String> entries=new ArrayList<>();
        for(Map.Entry<String,Object> entry:values.entrySet()) entries.add(q(entry.getKey())+":"+value(entry.getValue()));
        return "{"+String.join(",",entries)+"}";
    }
    static Map<Integer,List<String>> declarations(String specification) {
        Map<Integer,List<String>> result=new HashMap<>();
        for(String declaration:specification.split(",")) {
            if(declaration.isEmpty())continue;
            String[] pair=declaration.split(":",2);
            result.computeIfAbsent(Integer.parseInt(pair[0]),unused->new ArrayList<>()).add(pair[1]);
        }
        return result;
    }
    public static String frame(ParseTree tree,String specification) throws ReflectiveOperationException {
        return frame((ParserRuleContext)tree,declarations(specification));
    }
    static String frame(ParserRuleContext context,Map<Integer,List<String>> declarations) throws ReflectiveOperationException {
        Map<String,Object> values=new TreeMap<>();
        for(String name:declarations.getOrDefault(context.getRuleIndex(),Collections.emptyList())) {
            Field field;
            try { field=context.getClass().getField(name); }
            catch(NoSuchFieldException escapedKeyword) { field=context.getClass().getField(name+"_"); }
            values.put(name,field.get(context));
        }
        List<String> children=new ArrayList<>();
        for(int i=0;i<context.getChildCount();i++) if(context.getChild(i) instanceof ParserRuleContext)
            children.add(frame((ParserRuleContext)context.getChild(i),declarations));
        return "{\"values\":"+fields(values)+",\"children\":["+String.join(",",children)+"]}";
    }
    public static String shared(Parser parser) throws ReflectiveOperationException {
        Map<String,Object> values=new TreeMap<>();
        for(Field field:parser.getClass().getDeclaredFields()) {
            if(Modifier.isStatic(field.getModifiers()))continue;
            if(field.getType().isPrimitive()||field.getType()==String.class) {
                field.setAccessible(true);values.put(field.getName(),field.get(parser));
            }
        }
        return fields(values);
    }
}
