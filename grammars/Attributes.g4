grammar Attributes;
document returns [int total]
 : a=number[1] b=number[10] EOF {$total = $a.value + $b.value;}
 ;
number[int seed] returns [int value] locals [int seen]
 : INT {$seen = 1; $value = $seed + Integer.parseInt($INT.text);} {$value > 0}?
 ;
INT : [0-9]+;
WS : [ \t\r\n]+ -> skip;
