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
%token SEMI ";"
%token COMMA ","
%token LPAREN "("
%token RPAREN ")"
%token LBRACK "["
%token RBRACK "]"
%token LBRACE "{"
%token RBRACE "}"
%token ASSIGN "="
%token ID
%token NUM
%token UNKNOWN

%left EQ NEQ LT LE GT GE 
%left PLUS MINUS
%left TIMES OVER

%%

program: func-decl-list;

func-decl-list: func-decl-list func-decl 
	      | func-decl;

func-decl: func-header func-body;

func-header: ret-type ID "(" params ")";

func-body: "{" opt-var-decl opt-stmt-list "}";

opt-var-decl: %empty
	    | var-decl-list;

opt-stmt-list: %empty
	     | stmt-list;

ret-type: INT 
	| VOID;

params: VOID
      | param-list;

param-list: param-list "," param 
	  | param;

param: INT ID | INT ID "[" "]";

var-decl-list: var-decl-list var-decl
	     | var-decl;

var-decl: INT ID ";"
	| INT ID "[" NUM "]";

stmt-list: stmt-list stmt
	 | stmt;

stmt: assign-stmt
    | if-stmt 
    | while-stmt
    | return-stmt
    | func-call ";";

assign-stmt: lval "=" arith-expr ";";

lval: ID
    | ID "[" NUM "]" 
    | ID "[" ID "]";

if-stmt: IF "(" bool-expr ")" block
       | IF "(" bool-expr ")" block ELSE block;

block: "{" opt-stmt-list "}";

while-stmt: WHILE "(" bool-expr ")" block;

return-stmt: RETURN ";"
	   | RETURN arith-expr ";";

func-call: output-call
	 | write-call
	 | user-func-call;

input-call: INPUT "("")";

output-call: OUTPUT "(" arith-expr ")";

write-call: WRITE "(" STRING ")";

user-func-call: ID "(" opt-arg-list ")";

opt-arg-list: %empty
	    | arg-list;

arg-list: arg-list "," arith-expr
	| arith-expr;

bool-expr: arith-expr bool-op arith-expr;

bool-op: EQ | NEQ | LT | LE | GT | GE;

arith-expr: arith-expr arith-op arith-expr
	  | "(" arith-expr ")"
	  | lval 
	  | input-call
	  | user-func-call
	  | NUM;

arith-op: PLUS | MINUS | TIMES | OVER;

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
