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

%token STRING
%token IF ELSE
%token INPUT OUTPUT
%token INT
%token RETURN
%token VOID
%token WHILE
%token READ WRITE 
%token SEMI 
%token COMMA
%token LPAREN RPAREN
%token LBRACK RBRACK
%token LBRACE RBRACE
%token ASSIGN
%token ID
%token NUM

%left EQ NEQ LT LE GT GE 
%left PLUS MINUS
%left TIMES OVER

%%

program: func-decl-list;

func-decl-list: func-decl-list func-decl 
	      | func-decl;

func-decl: func-header func-body;

func-header: ret-type ID LPAREN params RPAREN;

func-body: LBRACE opt-var-decl opt-stmt-list RBRACE;

opt-var-decl: %empty
	    | var-decl-list;

opt-stmt-list: %empty
	     | stmt-list;

ret-type: INT 
	| VOID;

params: VOID
      | param-list;

param-list: param-list COMMA param 
	  | param;

param: INT ID | INT ID LBRACK RBRACK;

var-decl-list: var-decl-list var-decl
	     | var-decl;

var-decl: INT ID SEMI
	| INT ID LBRACK NUM RBRACK SEMI;

stmt-list: stmt-list stmt
	 | stmt;

stmt: assign-stmt
    | if-stmt 
    | while-stmt
    | return-stmt
    | func-call SEMI;

assign-stmt: lval ASSIGN arith-expr SEMI;

lval: ID
    | ID LBRACK NUM RBRACK 
    | ID LBRACK ID RBRACK;

if-stmt: IF LPAREN bool-expr RPAREN block
       | IF LPAREN bool-expr RPAREN block ELSE block;

block: LBRACE opt-stmt-list RBRACE;

while-stmt: WHILE LPAREN bool-expr RPAREN block;

return-stmt: RETURN SEMI
	   | RETURN arith-expr SEMI;

func-call: output-call
	 | write-call
	 | user-func-call;

input-call: INPUT LPAREN RPAREN;

output-call: OUTPUT LPAREN arith-expr RPAREN;

write-call: WRITE LPAREN STRING RPAREN;

user-func-call: ID LPAREN opt-arg-list RPAREN;

opt-arg-list: %empty
	    | arg-list;

arg-list: arg-list COMMA arith-expr
	| arith-expr;

bool-expr: arith-expr bool-op arith-expr;

bool-op: EQ | NEQ | LT | LE | GT | GE;

arith-expr: arith-expr PLUS arith-expr
	  | arith-expr MINUS arith-expr
	  | arith-expr TIMES arith-expr
	  | arith-expr OVER arith-expr
	  | LPAREN arith-expr RPAREN
	  | lval 
	  | input-call
	  | user-func-call
	  | NUM;

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
