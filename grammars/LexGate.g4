grammar LexGate;
document : (KEY | ID)* EOF;
KEY : 'if' {Boolean.getBoolean("moonantlr.predicate")}? ;
ID : [a-z]+;
WS : [ \t\r\n]+ -> skip;
