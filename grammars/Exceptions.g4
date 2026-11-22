grammar Exceptions;
@parser::members {
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
caught : 'a' 'b' { failIf("inline"); };
catch [RecognitionException error] { failIf("catch"); }
finally { failIf("finally"); }

caught_host : 'x' { failIf("inline"); };
catch [IllegalStateException error] { failIf("catch"); }
finally { failIf("finally"); }
WS : [ \t\r\n]+ -> skip;

specific : 'x' ('a' 'b' | 'a' 'x');
catch [NoViableAltException error] { failIf("no-viable"); }
catch [InputMismatchException error] { failIf("mismatch"); }
finally { failIf("finally"); }

predicate_failure : {false}? 'x';
catch [FailedPredicateException error] { failIf("predicate"); }
finally { failIf("finally"); }

outer : child=nested_callee;
catch [IllegalStateException error] { failIf("catch"); }
finally { failIf("finally"); }
nested_callee : 'x' { failIf("inline"); };
