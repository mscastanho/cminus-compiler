%option stack
%{
	#include <stdio.h>
	int linha = 1;
%}

/*comentarios de uma linha (one-line)*/
%x olcomment

/* comentarios multi-linha (multi-line) */ 
%x mlcomment

%%

"/*" { BEGIN(mlcomment); }
"//" { BEGIN(olcomment); }
<olcomment>\n { linha++; BEGIN(INITIAL);}
<INITIAL,mlcomment>\n { linha++; }
<mlcomment>.*"*/" {BEGIN(INITIAL);}
<mlcomment>.* {;}
<olcomment>[^"\n"] {;}
["].*["] {printf("%d: %s -> STRING\n",linha,yytext);}
"else" {printf("%d: %s -> ELSE\n",linha,yytext);}
"if" {printf("%d: %s -> IF\n",linha,yytext);}
"input" {printf("%d: %s -> INPUT\n",linha,yytext);}
"int" {printf("%d: %s -> INT\n",linha,yytext);}
"output" {printf("%d: %s -> OUTPUT\n",linha,yytext);}
"return" {printf("%d: %s -> RETURN\n",linha,yytext);}
"void" {printf("%d: %s -> VOID\n",linha,yytext);}
"while" {printf("%d: %s -> WHILE\n",linha,yytext);}
"write" {printf("%d: %s -> WRITE\n",linha,yytext);}
[a-zA-Z][a-zA-Z0-9]* {printf("%d: %s -> ID\n",linha,yytext);}
"+" {printf("%d: %s -> PLUS\n",linha,yytext);}
"-" {printf("%d: %s -> MINUS\n",linha,yytext);}
"*" {printf("%d: %s -> TIMES\n",linha,yytext);}
"/" {printf("%d: %s -> OVER\n",linha,yytext);}
"<" {printf("%d: %s -> LT\n",linha,yytext);}
"<=" {printf("%d: %s -> LE\n",linha,yytext);}
">" {printf("%d: %s -> GT\n",linha,yytext);}
">=" {printf("%d: %s -> GE\n",linha,yytext);}
"==" {printf("%d: %s -> EQ\n",linha,yytext);}
"!=" {printf("%d: %s -> NEQ\n",linha,yytext);}
"=" {printf("%d: %s -> ASSIGN\n",linha,yytext);}
";" {printf("%d: %s -> SEMI\n",linha,yytext);}
"," {printf("%d: %s -> COMMA\n",linha,yytext);}
"\(" {printf("%d: %s -> LPAREN\n",linha,yytext);}
"\)" {printf("%d: %s -> RPAREN\n",linha,yytext);}
"[" {printf("%d: %s -> LBRACK\n",linha,yytext);}
"]" {printf("%d: %s -> RBRACK\n",linha,yytext);}
"{" {printf("%d: %s -> LBRACE\n",linha,yytext);}
"}" {printf("%d: %s -> RBRACE\n",linha,yytext);}
[0-9]+ {printf("%d: %s -> NUM\n",linha,yytext);}
[ \t\n] ; //ignorar
.       {printf("%d: %s -> UNKNOWN\n",linha,yytext);}

%%

int main () {yylex(); return 0; }
int yywrap() {return 1;}

