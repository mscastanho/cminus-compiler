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
Queue* argList = NULL;


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
	%empty 			{ $$ = new_node("var-list"); }
    | var-decl-list { Tree* n = new_node("var-list"); varList = add_children_from_q(n,varList); $$ = n; }
	;

opt-stmt-list: 
	%empty		{ $$ = new_node("block"); }
    | stmt-list { Tree* n = new_node("block"); stmtList = add_children_from_q(n,stmtList); $$ = n; }
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
	| INT ID LBRACK NUM RBRACK SEMI		{ $$ = new_subtree("vetor",1,$4); } // ---------
	;

stmt-list: 
	stmt stmt-list 	{ stmtList = Q_addNode(stmtList,$1); }
	| stmt 			{ stmtList = Q_addNode(stmtList,$1); }
	;				

stmt: 
	assign-stmt			{ $$ = $1; }
    | if-stmt 			{ $$ = $1; }
    | while-stmt		{ $$ = $1; }
    | return-stmt		{ $$ = $1; }
    | func-call SEMI	{ $$ = $1; }
	;

assign-stmt: 
	lval ASSIGN arith-expr SEMI { $$ = new_subtree("=",2,$1,$3); }
	;

lval: 
	ID							{ $$ = $1; }
    | ID LBRACK NUM RBRACK 		{ $$ = new_subtree("vetor",1,$3); }
    | ID LBRACK ID RBRACK		{ $$ = new_subtree("vetor",1,$3); }
	;

if-stmt: 
	IF LPAREN bool-expr RPAREN block				{ $$ = new_subtree("if",2,$3,$5); }
    | IF LPAREN bool-expr RPAREN block ELSE block	{ $$ = new_subtree("if",3,$3,$5,$7); }
	;

block: 
	LBRACE opt-stmt-list RBRACE { $$ = $2; }
	;

while-stmt: 
	WHILE LPAREN bool-expr RPAREN block { $$ = new_subtree("while",2,$3,$5); }
	;

return-stmt: 
	RETURN SEMI					{ $$ = new_node("return"); }
	| RETURN arith-expr SEMI	{ $$ = new_subtree("return",1,$2); }
	;

func-call: 
	output-call			{ $$ = $1; }
	| write-call		{ $$ = $1; }
	| user-func-call	{ $$ = $1; }
	;

input-call: 
	INPUT LPAREN RPAREN { $$ = new_node("input"); }
	;

output-call: 
	OUTPUT LPAREN arith-expr RPAREN { $$ = new_subtree("output",1,$3); }
	;

write-call: 
	WRITE LPAREN STRING RPAREN { Tree* s = new_node("string"); $$ = new_subtree("write",1,s); } //checar string
	;

user-func-call: 
	ID LPAREN opt-arg-list RPAREN { $$ = new_subtree("user_func",1,$3); } // checar funcao
	;

opt-arg-list: 
	%empty 	   { $$ = new_node("arg-list");;}
    | arg-list { Tree* n = new_node("arg-list"); argList = add_children_from_q(n,argList); $$ = n; }
	;

arg-list: 
	arith-expr COMMA arg-list 	{ argList = Q_addNode(argList,$1); }
	| arith-expr			  	{ argList = Q_addNode(argList,$1); }
	;

bool-expr: 
	arith-expr EQ arith-expr 	{ $$ = new_subtree("==",2,$1,$3); }
	| arith-expr NEQ arith-expr { $$ = new_subtree("!=",2,$1,$3); }
	| arith-expr LT arith-expr 	{ $$ = new_subtree("<",2,$1,$3);  }
	| arith-expr LE arith-expr 	{ $$ = new_subtree("<=",2,$1,$3); }
	| arith-expr GT arith-expr 	{ $$ = new_subtree(">",2,$1,$3);  }
	| arith-expr GE arith-expr 	{ $$ = new_subtree(">=",2,$1,$3); }
	;

//bool-op: EQ | NEQ | LT | LE | GT | GE;

arith-expr: 
	arith-expr PLUS arith-expr 		{ $$ = new_subtree("+",2,$1,$3); }
	| arith-expr MINUS arith-expr	{ $$ = new_subtree("-",2,$1,$3); }
	| arith-expr TIMES arith-expr	{ $$ = new_subtree("*",2,$1,$3); }
	| arith-expr OVER arith-expr	{ $$ = new_subtree("/",2,$1,$3); }
	| LPAREN arith-expr RPAREN		{ $$ = new_subtree("+",1,$2); 	 }
	| lval 							{ $$ = $1; }
	| input-call					{ $$ = $1; }
	| user-func-call				{ $$ = $1; } //checar funcao
	| NUM							{ $$ = $1; }	
	;

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
