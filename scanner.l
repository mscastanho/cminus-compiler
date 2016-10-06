%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{
	#include "parser.h"
	#include <stdio.h>
%}

/*comentarios de uma linha (one-line)*/
%x olcomment

/* comentarios multi-linha (multi-line) */ 
%x mlcomment

%%

"/*" { BEGIN(mlcomment); }
"//" { BEGIN(olcomment); }
<olcomment>\n { yylineno++; BEGIN(INITIAL);}
<INITIAL,mlcomment>\n { yylineno++; }
<mlcomment>.*"*/" {BEGIN(INITIAL);}
<mlcomment>.* {;}
<olcomment>[^"\n"] {;}
["].*["] {return STRING;}
"else" {return ELSE;}
"if" {return IF;}
"input" {return INPUT;}
"int" {return INT;}
"output" {return OUTPUT;}
"return" {return RETURN;}
"void" {return VOID;}
"while" {return WHILE;}
"write" {return WRITE;}
[a-zA-Z][a-zA-Z0-9]* {return ID;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return TIMES;}
"/" {return OVER;}
"<" {return LT;}
"<=" {return LE;}
">" {return GT;}
">=" {return GE;}
"==" {return EQ;}
"!=" {return NEQ;}
"=" {return ASSIGN;}
";" {return SEMI;}
"," {return COMMA;}
"\(" {return LPAREN;}
"\)" {return RPAREN;}
"[" {return LBRACK;}
"]" {return RBRACK;}
"{" {return LBRACE;}
"}" {return RBRACE;}
[0-9]+ {return NUM;}
[ \t\n] ; //ignorar
.       {printf("SCANNING ERROR (%d): Unknown symbol %s\n",yylineno,yytext); exit(1);}


