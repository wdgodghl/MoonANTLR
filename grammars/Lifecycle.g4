grammar Lifecycle;
@parser::members { public final java.util.List<Integer> offsets = new java.util.ArrayList<>(); }
document returns [int total]
@init { $total = 1; offsets.add(100 + getCurrentToken().getStartIndex()); }
@after { $total += 10; offsets.add(1000 + getCurrentToken().getStartIndex()); }
 : 'x' { $total += 100; offsets.add(10000 + getCurrentToken().getStartIndex()); } EOF;
finally { $total += 1000; offsets.add(100000 + getCurrentToken().getStartIndex()); }
broken returns [int total]
@init { $total = 1; offsets.add(100 + getCurrentToken().getStartIndex()); }
@after { $total += 10; offsets.add(1000 + getCurrentToken().getStartIndex()); }
 : 'a' 'b' { $total += 100; offsets.add(10000 + getCurrentToken().getStartIndex()); };
finally { $total += 1000; offsets.add(100000 + getCurrentToken().getStartIndex()); }
set_sequence : values+=('a'|'b') values+=('c'|'d') values+=('e'|'f') EOF;
set_loop : values+=('a'|'b') (',' values+=('c'|'d'))* EOF;
WS : [ \t\r\n]+ -> skip;
