%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{
#include <stdio>
#include "tree.h"
#include "parser.h"
#include "tables.h"
#include <string.h>

#define process_token(type) yylval = new_node(yytext); return type

extern LitTable* literals;
extern SymTable* symbols; 
char idRead[100];

%}

/*comentarios de uma linha (one-line)*/
%x olcomment

/* comentarios multi-linha (multi-line) */ 
%x mlcomment

%%

"/*" 					{ BEGIN(mlcomment); }
"//" 					{ BEGIN(olcomment); }
<olcomment>\n 			{ yylineno++; BEGIN(INITIAL);}
<INITIAL,mlcomment>\n 	{ yylineno++; }
<mlcomment>.*"*/" 		{BEGIN(INITIAL);}
<mlcomment>.* 			{;}
<olcomment>[^"\n"] 		{;}
["].*["] 				{process_token(STRING);}
"else" 					{process_token(ELSE);}
"if" 					{process_token(IF);}
"input" 				{process_token(INPUT);}
"int" 					{process_token(INT);}
"output" 				{process_token(OUTPUT);}
"return" 				{process_token(RETURN);}
"void" 					{process_token(VOID);}
"while" 				{process_token(WHILE);}
"write" 				{process_token(WRITE);}
[a-zA-Z][a-zA-Z0-9]* 	{process_token(ID);}
"+" 					{process_token(PLUS);}
"-" 					{process_token(MINUS);}
"*" 					{process_token(TIMES);}
"/" 					{process_token(OVER);}
"<" 					{process_token(LT);}
"<=" 					{process_token(LE);}
">" 					{process_token(GT);}
">=" 					{process_token(GE);}
"==" 					{process_token(EQ);}
"!=" 					{process_token(NEQ);}
"=" 					{process_token(ASSIGN);}
";" 					{return SEMI;}
"," 					{return COMMA;}
"\(" 					{return LPAREN;}
"\)" 					{return RPAREN;}
"[" 					{return LBRACK;}
"]" 					{return RBRACK;}
"{" 					{return LBRACE;}
"}" 					{return RBRACE;}
[0-9]+ 					{return NUM;}
[ \t\n] ; //ignorar
.       {printf("SCANNING ERROR (%d): Unknown symbol %s\n",yylineno,yytext); exit(1);}


