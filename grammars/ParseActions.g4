grammar ParseActions;
@parser::members {
    public final java.util.List<Integer> offsets = new java.util.ArrayList<>();
}
document : {offsets.add(getCurrentToken().getStartIndex());} item+
           {offsets.add(getCurrentToken().getStartIndex());} EOF;
item : 'a' {offsets.add(getCurrentToken().getStartIndex());} 'b'
     | 'a' {offsets.add(getCurrentToken().getStartIndex());} 'c'
     | 'expr' expression;
expression : expression '+' {offsets.add(getCurrentToken().getStartIndex());} INT
           | INT;
INT : [0-9]+;
WS : [ \t\r\n]+ -> skip;
