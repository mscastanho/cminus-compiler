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
#include <stdlib.h>
#include <stdio.h>
#include "tree.h"
#include "queue.h"
#include "tables.h"

int yylex(void);
void yyerror(char const *s);
Queue* add_children_from_q(Tree* parent, Queue* list);
int check_var_rdcl(int sym_table_pos);
void check_var_ndcl(int sym_table_pos);
int check_func_rdcl(int func_table_pos, int arity);
void check_func_ndcl(int func_table_pos, int arity);

extern int yylineno;
extern char idRead[100];

Tree *ast;
Queue* paramList = NULL; 
Queue* funcList = NULL;
Queue* varList = NULL;
Queue* stmtList = NULL;
Queue* argList = NULL;

LitTable* literals;
SymTable* symbols;
FuncTable* functions;

#define VAR_RDCL_ERROR_MSG "SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n"
#define VAR_NDCL_ERROR_MSG "SEMANTIC ERROR (%d): variable '%s' was not declared.\n"  

#define FUNC_RDCL_ERROR_MSG "SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n"
#define FUNC_NDCL_ERROR_MSG "SEMANTIC ERROR (%d): function '%s' was not declared.\n"  
#define FUNC_NARG_ERROR_MSG "SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters"
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
	func-decl-list { ast = new_node(PROGRAM,0); funcList = add_children_from_q(ast,funcList);   }
	;

func-decl-list: 
	func-decl func-decl-list { funcList = Q_addNode(funcList,$1); } 
    | func-decl 			 { funcList = Q_addNode(funcList,$1); }
	;

func-decl: 
	func-header func-body { clean_sym_table(symbols); // The scope of a variable is only the function where it was defined 
							$$ = new_subtree(FUNC_DECL,0,2,$1,$2); }
	;

func-header: 
	ret-type ID LPAREN params RPAREN { int tablePos = get_tree_data($2);
									   int arity = get_tree_data($4); // Number of parameters is saved in data field of 'params'  
									   check_func_rdcl(tablePos,arity); 
									   $$ = new_subtree(FUNC_HEADER,0,3,$1,$2,$4); }
	;

func-body: 
	LBRACE opt-var-decl opt-stmt-list RBRACE { $$ = new_subtree(FUNC_BODY,0,2,$2,$3); }
	;
	
opt-var-decl: 
	%empty 			{ $$ = new_node(VAR_LIST,0); }
    | var-decl-list { Tree* n = new_node(VAR_LIST,0); 
					  varList = add_children_from_q(n,varList); 
					  $$ = n; }
	;

opt-stmt-list: 
	%empty		{ $$ = new_node(BLOCK,0); }
    | stmt-list { Tree* n = new_node(BLOCK,0); 
				  stmtList = add_children_from_q(n,stmtList); 
				  $$ = n; }
	;

ret-type: 
	INT		{ $$ = $1; } 
	| VOID	{ $$ = $1; }
	;

params: 
	VOID			{ $$ = new_node(PARAMS,0); }
	| param-list	{ int nParams = get_children_number($1); 
					  Tree* n = new_node(PARAMS,nParams); 
					  paramList = add_children_from_q(n,paramList); 
					  $$ = n; }
	;

param-list: 
	param COMMA param-list { paramList = Q_addNode(paramList,$1); }
  	| param				   { paramList = Q_addNode(paramList,$1); } 
	;

param: 
	INT ID						{ int pos = add_var(symbols,idRead,yylineno); 
								  $$ = new_node(SVAR,pos); }
	| INT ID LBRACK RBRACK		{ int pos = add_var(symbols,idRead,yylineno); 
								  $$ = new_node(CVAR,pos); }
	;

var-decl-list: 
	var-decl var-decl-list { varList = Q_addNode(varList,$1); }
    | var-decl			   { varList = Q_addNode(varList,$1); }
	;

var-decl: 
	INT ID SEMI							{ int pos = get_tree_data($2);
										  pos = check_var_rdcl(pos); 
										  $$ = new_node(SVAR,pos); }
	| INT ID LBRACK NUM RBRACK SEMI		{ int pos = get_tree_data($2);
										  pos = check_var_rdcl(pos); 
										  $$ = new_subtree(CVAR,pos,1,$4); }
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
	lval ASSIGN arith-expr SEMI { $$ = new_subtree(_ASSIGN,0,2,$1,$3); }
	;

lval: 
	ID							{ int pos = get_tree_data($1);
								  check_var_ndcl(pos); 
								  $$ = new_node(SVAR,pos); }
    | ID LBRACK NUM RBRACK 		{ int pos = get_tree_data($1); 
								  check_var_ndcl(pos);
								  $$ = new_subtree(CVAR,pos,1,$3); }
    | ID LBRACK ID RBRACK		{ int pos = get_tree_data($1);
								  check_var_ndcl(pos);
								  $$ = new_subtree(CVAR,pos,1,$3); }
	;

if-stmt: 
	IF LPAREN bool-expr RPAREN block				{ $$ = new_subtree(_IF,0,2,$3,$5); }
    | IF LPAREN bool-expr RPAREN block ELSE block	{ $$ = new_subtree(_IF,0,3,$3,$5,$7); }
	;

block: 
	LBRACE opt-stmt-list RBRACE { $$ = $2; }
	;

while-stmt: 
	WHILE LPAREN bool-expr RPAREN block { $$ = new_subtree(_WHILE,0,2,$3,$5); }
	;

return-stmt: 
	RETURN SEMI					{ $$ = new_node(_RETURN,0); }
	| RETURN arith-expr SEMI	{ $$ = new_subtree(_RETURN,0,1,$2); }
	;

func-call: 
	output-call			{ $$ = $1; }
	| write-call		{ $$ = $1; }
	| user-func-call	{ $$ = $1; }
	;

input-call: 
	INPUT LPAREN RPAREN { $$ = new_node(_INPUT,0); }
	;

output-call: 
	OUTPUT LPAREN arith-expr RPAREN { $$ = new_subtree(_OUTPUT,0,1,$3); }
	;

write-call: 
	WRITE LPAREN STRING RPAREN { int ltPos = get_tree_data($3);
								 Tree* s = new_node(_STRING,ltPos); 
								 $$ = new_subtree(WRITE,0,1,s); }
	;

user-func-call: 
	ID LPAREN opt-arg-list RPAREN { int ftPos = get_tree_data2($1);
									int arity = get_tree_data($3);
									check_func_ndcl(ftPos,arity); 
									$$ = new_subtree(USER_FUNC,ftPos,1,$3); }
	;

opt-arg-list: 
	%empty 	   { $$ = new_node(ARG_LIST,0);}
    | arg-list { int nArgs = get_children_number($1);
				 Tree* n = new_node(ARG_LIST,nArgs); // Node of type ARG_LIST has number of arguments in 'data' field 
				 argList = add_children_from_q(n,argList); 
				 $$ = n; }
	;

arg-list: 
	arith-expr COMMA arg-list 	{ argList = Q_addNode(argList,$1); }
	| arith-expr			  	{ argList = Q_addNode(argList,$1); }
	;

bool-expr: 
	arith-expr EQ arith-expr 	{ $$ = new_subtree(_EQ,0,2,$1,$3); }
	| arith-expr NEQ arith-expr { $$ = new_subtree(_NEQ,0,2,$1,$3); }
	| arith-expr LT arith-expr 	{ $$ = new_subtree(_LT,0,2,$1,$3);  }
	| arith-expr LE arith-expr 	{ $$ = new_subtree(_LE,0,2,$1,$3); }
	| arith-expr GT arith-expr 	{ $$ = new_subtree(_GT,0,2,$1,$3);  }
	| arith-expr GE arith-expr 	{ $$ = new_subtree(_GT,0,2,$1,$3); }
	;

arith-expr: 
	arith-expr PLUS arith-expr 		{ $$ = new_subtree(_PLUS,0,2,$1,$3); }
	| arith-expr MINUS arith-expr	{ $$ = new_subtree(_MINUS,0,2,$1,$3); }
	| arith-expr TIMES arith-expr	{ $$ = new_subtree(_TIMES,0,2,$1,$3); }
	| arith-expr OVER arith-expr	{ $$ = new_subtree(_OVER,0,2,$1,$3); }
	| LPAREN arith-expr RPAREN		{ $$ = $2; }
	| lval 							{ $$ = $1; }
	| input-call					{ $$ = $1; }
	| user-func-call				{ $$ = $1; }
	| NUM							{ $$ = $1; }	
	;

%%

// Error handling
void yyerror (char const *s){
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
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

int check_var_rdcl(int sym_table_pos){
	if(sym_table_pos == -1) 
		return add_var(symbols,idRead,yylineno);
	else{
		printf(VAR_RDCL_ERROR_MSG,yylineno,idRead,get_line(symbols,sym_table_pos));
		exit(1);
		return 0;								
	}
}

void check_var_ndcl(int sym_table_pos){
	if(sym_table_pos == -1){
		printf(VAR_NDCL_ERROR_MSG,yylineno,idRead);
		exit(1);
	}
}

int check_func_rdcl(int func_table_pos, int arity){
	if(func_table_pos == -1) 
		return add_func(functions,idRead,arity,yylineno);
	else{
		printf(FUNC_RDCL_ERROR_MSG,yylineno,idRead,get_func_line(functions,func_table_pos));
		exit(1);
		return 0;								
	}
}

void check_func_ndcl(int func_table_pos, int arity){
	if(func_table_pos == -1){
		printf(FUNC_NDCL_ERROR_MSG,yylineno,idRead);
		exit(1);
	}else{
		int declaredArity = get_func_arity(functions, func_table_pos);
			
		if(declaredArity != arity)
			printf(FUNC_NARG_ERROR_MSG,yylineno,idRead,arity,declaredArity);
	}
}


int main() {
  //yydebug = 1; // Enter debug mode.

	literals = create_lit_table();
 	symbols = create_sym_table();
	functions = create_func_table();

	if (yyparse() == 0){
		print_dot(ast);
		//free_tree(ast);
		//printf("PARSE SUCESSFUL!\n");
	}

  	return 0;
}
