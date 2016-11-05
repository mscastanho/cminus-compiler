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
char idRead[100];

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

"if" 					{ yylval = new_node(_IF,0); 
						 return IF;}

"input" 				{ yylval = new_node(_INPUT,0); 
				 		  return INPUT;}

"int" 					{ yylval = new_node(_INT,0); 
						  return INT;}

"output" 				{ yylval = new_node(_OUTPUT,0); 
						  return OUTPUT;}

"return" 				{ yylval = new_node(_RETURN,0);
						  return RETURN;}

"void" 					{ yylval = new_node(_VOID,0); 
						  return VOID;}

"while" 				{ yylval = new_node(_WHILE,0); 
						  return WHILE;}

"write" 				{ yylval = new_node(_WRITE,0); 
						  return WRITE;}

[a-zA-Z][a-zA-Z0-9]* 	{ int stPos = lookup_var(symbols,yytext);
						  strcpy(idRead,yytext); 
						  yylval = new_node(_ID,stPos);
						  int ftPos = lookup_func(functions,yytext);
						  set_tree_data2(yylval,ftPos); 
						  return ID;}

"+" 					{ yylval = new_node(_PLUS,0); 
						  return PLUS;}

"-" 					{ yylval = new_node(_MINUS,0); 
						  return MINUS;}

"*" 					{ yylval = new_node(_TIMES,0); 
						  return TIMES;}

"/" 					{ yylval = new_node(_OVER,0); 
						  return OVER;}

"<" 					{ yylval = new_node(_LT,0); 
						  return LT;}

"<=" 					{ yylval = new_node(_LE,0);
						  return LE;}

">" 					{ yylval = new_node(_GT,0);  
						  return GT;}

">=" 					{ yylval = new_node(_GE,0); 
						  return GE;}

"==" 					{ yylval = new_node(_EQ,0); 
						  return EQ;}

"!=" 					{ yylval = new_node(_NEQ,0); 
						  return NEQ;}

"=" 					{ yylval = new_node(_ASSIGN,0); 
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


