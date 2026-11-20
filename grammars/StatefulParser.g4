parser grammar StatefulParser;
options { tokenVocab=StatefulLexer; }
document : (STRING | WORD)* EOF;
