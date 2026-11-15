grammar Predicate;
document : (enabled | fallback) EOF;
enabled : {Boolean.getBoolean("moonantlr.predicate")}? INT;
fallback : INT;
INT : [0-9]+;
