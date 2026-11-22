grammar Lifecycle;
@parser::members {
 public final java.util.List<Integer> offsets = new java.util.ArrayList<>();
 public final java.util.List<String> visits = new java.util.ArrayList<>();
 public int commits = 0;
 public final java.util.List<Integer> finalCounts = new java.util.ArrayList<>();
 public final java.util.List<Integer> totals = new java.util.ArrayList<>();
 public String failStages = "";
 public void failIf(String stage) {
   commits++;
   visits.add(stage);
   if (stage.equals("finally") || stage.equals("outer-finally")) finalCounts.add(commits);
   if (("," + failStages + ",").contains("," + stage + ",")) throw new IllegalStateException(stage);
 }
}
document returns [int total]
@init { failIf("init"); $total = 1; offsets.add(100 + getCurrentToken().getStartIndex()); }
@after { $total += 10; failIf("after"); offsets.add(1000 + getCurrentToken().getStartIndex()); }
 : 'x' { $total += 100; failIf("inline"); offsets.add(10000 + getCurrentToken().getStartIndex()); } EOF;
finally { $total += 1000; totals.add($total); failIf("finally"); offsets.add(100000 + getCurrentToken().getStartIndex()); }
broken returns [int total]
@init { $total = 1; offsets.add(100 + getCurrentToken().getStartIndex()); }
@after { $total += 10; offsets.add(1000 + getCurrentToken().getStartIndex()); }
 : 'a' 'b' { $total += 100; offsets.add(10000 + getCurrentToken().getStartIndex()); };
finally { $total += 1000; offsets.add(100000 + getCurrentToken().getStartIndex()); }
set_sequence : values+=('a'|'b') values+=('c'|'d') values+=('e'|'f') EOF;
set_loop : values+=('a'|'b') (',' values+=('c'|'d'))* EOF;
nested
@init { failIf("outer-init"); }
@after { failIf("outer-after"); }
 : document;
finally { failIf("outer-finally"); }
WS : [ \t\r\n]+ -> skip;
