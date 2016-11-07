%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{
#include <stdio.h>
#include "tree.h"
#include "parser.h"
#include "tables.h"
#include <string.h>

#define process_token(type) yylval = new_node(_type); return type

extern LitTable* literals;
extern SymTable* symbols;
extern FuncTable* functions;
char idRead[256];

%}

/*comentarios de uma linha (one-line)*/
%x olcomment

/* comentarios multi-linha (multi-line) */ 
%x mlcomment

%%

"/*" 					{ BEGIN(mlcomment); }

"//" 					{ BEGIN(olcomment); }

<olcomment>\n 			{ yylineno++; 
						  BEGIN(INITIAL);}

<INITIAL,mlcomment>\n 	{ yylineno++; }

<mlcomment>.*"*/" 		{ BEGIN(INITIAL);}

<mlcomment>.* 			{;}

<olcomment>[^"\n"] 		{;}

["].*["] 				{ int ltPos = add_literal(literals,yytext);
						  yylval = new_node(_STRING,ltPos); 
						  return STRING;}

"else" 					{ return ELSE;}

"if" 					{ yylval = new_node(_IF,-1); 
						 return IF;}

"input" 				{ yylval = new_node(_INPUT,-1); 
				 		  return INPUT;}

"int" 					{ yylval = new_node(_INT,-1); 
						  return INT;}

"output" 				{ yylval = new_node(_OUTPUT,-1); 
						  return OUTPUT;}

"return" 				{ yylval = new_node(_RETURN,-1);
						  return RETURN;}

"void" 					{ yylval = new_node(_VOID,-1); 
						  return VOID;}

"while" 				{ yylval = new_node(_WHILE,-1); 
						  return WHILE;}

"write" 				{ yylval = new_node(_WRITE,-1); 
						  return WRITE;}

[a-zA-Z][a-zA-Z0-9]* 	{ strcpy(idRead,yytext);
						  int stPos = lookup_var(symbols,yytext);
						  yylval = new_node(_ID,stPos); 
						  return ID;}

"+" 					{ yylval = new_node(_PLUS,-1); 
						  return PLUS;}

"-" 					{ yylval = new_node(_MINUS,-1); 
						  return MINUS;}

"*" 					{ yylval = new_node(_TIMES,-1); 
						  return TIMES;}

"/" 					{ yylval = new_node(_OVER,-1); 
						  return OVER;}

"<" 					{ yylval = new_node(_LT,-1); 
						  return LT;}

"<=" 					{ yylval = new_node(_LE,-1);
						  return LE;}

">" 					{ yylval = new_node(_GT,-1);  
						  return GT;}

">=" 					{ yylval = new_node(_GE,-1); 
						  return GE;}

"==" 					{ yylval = new_node(_EQ,-1); 
						  return EQ;}

"!=" 					{ yylval = new_node(_NEQ,-1); 
						  return NEQ;}

"=" 					{ yylval = new_node(_ASSIGN,-1); 
						  return ASSIGN;}

";" 					{ return SEMI;}

"," 					{ return COMMA;}

"\(" 					{ return LPAREN;}

"\)" 					{ return RPAREN;}

"[" 					{ return LBRACK;}

"]" 					{ return RBRACK;}

"{" 					{ return LBRACE;}

"}" 					{ return RBRACE;}

[0-9]+ 					{ yylval = new_node(_NUM,atoi(yytext)); 
						  return NUM;}

[ \t\n] 				; 	//ignorar

.       				{ printf("SCANNING ERROR (%d): Unknown symbol %s\n",yylineno,yytext); 
						  exit(1);}


