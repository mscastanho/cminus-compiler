/* Options to bison */
// File name of generated parser.
%output "parser.c"
// Produces a 'parser.h'
%defines "parser.h"
// Give proper error messages when a syntax error is found.
%define parse.error verbose
// Enable LAC (lookahead correction) to improve syntax error handling.
%define parse.lac full

// Enable the trace option so that debugging is possible.
%define parse.trace

%{
#include <stdio.h>

int yylex(void);
void yyerror(char const *s);

extern int yylineno;
%}

%token IF THEN ELSE END
%token REPEAT UNTIL READ WRITE
%token OP CP 
%token SEMI 
%token ASSIGN
%token ID
%token NUM
//%token UNKNOWN

%left EQ LT
%left PLUS MINUS
%left TIMES OVER

%%

program: stmt-sequence;

stmt-sequence: stmt-sequence stmt
				 | stmt
				 ;

stmt: if-stmt
	 | repeat-stmt
	 | assign-stmt
	 | read-stmt
	 | write-stmt
	 ;

if-stmt: IF expr THEN stmt-sequence END
	    | IF expr THEN stmt-sequence ELSE stmt-sequence END
		 ;

repeat-stmt: REPEAT stmt-sequence UNTIL expr;

assign-stmt: ID ASSIGN expr SEMI;

read-stmt: READ ID SEMI;

write-stmt: WRITE expr SEMI;

expr: expr LT expr
	 | expr EQ expr
	 | expr PLUS expr
	 | expr MINUS expr
	 | expr TIMES expr
	 | expr OVER expr
	 | OP expr CP
	 | NUM
	 | ID
	 ;

%%

// Error handling
void yyerror (char const *s){
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
}

int main() {
  //yydebug = 1; // Enter debug mode.

  if (yyparse() == 0){
		printf("PARSE SUCESSFUL!\n");
  }
  return 0;
}
