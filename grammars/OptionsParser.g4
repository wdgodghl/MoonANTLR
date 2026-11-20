parser grammar OptionsParser;
options { tokenVocab = OptionsLexer; }
import ImportedRules;
document : values+=atom (ALIAS values+=atom)* EOF;
