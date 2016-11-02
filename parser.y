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
#include "tree.h"
#include "queue.h"

int yylex(void);
void yyerror(char const *s);
void add_children_from_list(Tree* parent, Tree** list, int* idx);
Queue* add_children_from_q(Tree* parent, Queue* list);

extern int yylineno;

Tree *ast;
Queue* paramList = NULL; 
Queue* funcList = NULL;
Queue* varList = NULL;
Queue* stmtList = NULL;


%}

%define api.value.type {Tree*}

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

%start program

%%

program: 
	func-decl-list { ast = new_node("program"); funcList = add_children_from_q(ast,funcList);   }
	;

func-decl-list: 
	func-decl func-decl-list { funcList = Q_addNode(funcList,$1); } 
    | func-decl 			 { funcList = Q_addNode(funcList,$1); }
	;

func-decl: 
	func-header func-body { $$ = new_subtree("func-decl",2,$1,$2); }
	;

func-header: 
	ret-type ID LPAREN params RPAREN { $$ = new_subtree("func-header",3,$1,$2,$4); }
	;

func-body: 
	LBRACE opt-var-decl opt-stmt-list RBRACE { $$ = new_subtree("func-body",2,$2,$3); }
	;
	
opt-var-decl: 
	%empty
    | var-decl-list { Tree* n = new_node("var-list"); varList = add_children_from_q(n,varList); $$ = n; }
	;

opt-stmt-list: 
	%empty
    | stmt-list { $$ = $1; }
	;

ret-type: 
	INT		{ $$ = $1; } 
	| VOID	{ $$ = $1; }
	;

params: 
	VOID			{ $$ = new_subtree("params",0); }
	| param-list	{ Tree* n = new_node("params"); paramList = add_children_from_q(n,paramList); $$ = n; }
	;

param-list: 
	param COMMA param-list { paramList = Q_addNode(paramList,$1); }
  	| param				   { paramList = Q_addNode(paramList,$1); } 
	;

param: 
	INT ID						{ $$ = $1; } // diferenciar constante de vetor
	| INT ID LBRACK RBRACK		{ $$ = $1; } // -----	
	;

var-decl-list: 
	var-decl var-decl-list { varList = Q_addNode(varList,$1); }
    | var-decl			   { varList = Q_addNode(varList,$1); }
	;

var-decl: 
	INT ID SEMI							{ $$ = $1; } // diferenciar constante de vetor
	| INT ID LBRACK NUM RBRACK SEMI		{ $$ = $1; } // ---------
	;

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

void add_children_from_list(Tree* parent, Tree** list, int* idx){
	int i; 

	for(i=0;i<*idx;i++) 
		add_child(parent,list[i]);

	*idx = 0;
}

Queue* add_children_from_q(Tree* parent, Queue* list){
	Tree* t = NULL;

	do{
		list = Q_removeNode(list,&t);		
		
		if(t != NULL)
			add_child(parent,t);

	}while(list != NULL);

	return list;
}

// Error handling
void yyerror (char const *s){
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
}

int main() {
  //yydebug = 1; // Enter debug mode.

  if (yyparse() == 0){
	print_dot(ast);
	//free_tree(ast);
	//printf("PARSE SUCESSFUL!\n");
  }
  return 0;
}
