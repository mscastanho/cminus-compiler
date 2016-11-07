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
#include <string.h>
#include "tree.h"
#include "list.h"
#include "tables.h"

#define VAR_RDCL_ERROR_MSG "SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n"
#define VAR_NDCL_ERROR_MSG "SEMANTIC ERROR (%d): variable '%s' was not declared.\n"

#define FUNC_RDCL_ERROR_MSG "SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n"
#define FUNC_NDCL_ERROR_MSG "SEMANTIC ERROR (%d): function '%s' was not declared.\n"
#define FUNC_NARG_ERROR_MSG "SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n"

int yylex(void);
void yyerror(char const *s);
List* add_children_from_stack(Tree* parent, List* stack);
int check_var_rdcl(int sym_table_pos);
void check_var_ndcl(int sym_table_pos);
int check_func_rdcl(int func_table_pos, int arity);
void check_func_ndcl(int func_table_pos, int arity);

Tree *ast;
List* paramList = NULL;
List* funcList = NULL;
List* varList = NULL;
List* stmtList = NULL;
List* argList = NULL;
char tmpStr[256];

LitTable* literals;
SymTable* symbols;
FuncTable* functions;

int currentScope = 0;

extern int yylineno;
extern char idRead[256];

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
%token NUM
%token ID


%left EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES OVER

%start program

%%

program:
	func-decl-list { ast = new_node(FUNC_LIST,0); funcList = add_children_from_stack(ast,funcList);   }
	;

func-decl-list:
	func-decl func-decl-list { funcList = L_pushBack(funcList,$1); }
    | func-decl 			 { funcList = L_pushBack(funcList,$1); }
	;

func-decl:
	func-header func-body { $$ = new_subtree(FUNC_DECL,0,2,$1,$2); }
	;

func-header:
	ret-type ID { strcpy(tmpStr,idRead); } LPAREN params RPAREN { int ftPos = lookup_func(functions,tmpStr);
																  int arity = get_children_number($5);
									   							  ftPos = check_func_rdcl(ftPos,arity);
																  set_tree_data($2,ftPos);
									   							  $$ = new_subtree(FUNC_HEADER,0,3,$1,$2,$5); }
	;

func-body:
	LBRACE opt-var-decl opt-stmt-list RBRACE { $$ = new_subtree(FUNC_BODY,0,2,$2,$3);
											   currentScope++; }
	;

opt-var-decl:
	%empty 			{ $$ = new_node(VAR_LIST,0); }
    | var-decl-list { Tree* n = new_node(VAR_LIST,0);
					  varList = add_children_from_stack(n,varList);
					  $$ = n; }
	;

opt-stmt-list:
	%empty		{ $$ = new_node(BLOCK,0); }
    | stmt-list { Tree* n = new_node(BLOCK,0);
				  stmtList = add_children_from_stack(n,stmtList);
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
					  paramList = add_children_from_stack(n,paramList);
					  $$ = n; }
	;

param-list:
	param COMMA param-list { paramList = L_pushBack(paramList,$1); }
  	| param				   { paramList = L_pushBack(paramList,$1); }
	;

param:
	INT ID						{ int pos = add_var(symbols,idRead,yylineno,currentScope);
								  $$ = new_node(SVAR,pos); }
	| INT ID LBRACK RBRACK		{ int pos = add_var(symbols,idRead,yylineno,currentScope);
								  $$ = new_node(CVAR,pos); }
	;

var-decl-list:
	var-decl var-decl-list { varList = L_pushBack(varList,$1); }
    | var-decl			   { varList = L_pushBack(varList,$1); }
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
	stmt stmt-list 	{ stmtList = L_pushBack(stmtList,$1); }
	| stmt 			{ stmtList = L_pushBack(stmtList,$1); }
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
								  set_tree_type($3,SVAR);
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
								 $$ = new_subtree(_WRITE,0,1,s); }
	;

user-func-call:
	ID {strcpy(tmpStr,idRead);} LPAREN opt-arg-list RPAREN { int ftPos = lookup_func(functions,tmpStr);
															 set_tree_data($1,ftPos);
															 int arity = get_children_number($4);
																//printf("arity: %d\n",arity);
																//print_node($4,0);
															 check_func_ndcl(ftPos,arity);
															 $$ = new_subtree(USER_FUNC,ftPos,1,$4); }
	;

opt-arg-list:
	%empty 	   { $$ = new_node(ARG_LIST,0);}
    | arg-list { int nArgs = get_children_number($1);
				 Tree* n = new_node(ARG_LIST,nArgs); // Node of type ARG_LIST has number of arguments in 'data' field
				 argList = add_children_from_stack(n,argList);
				 $$ = n; }
	;

arg-list:
	arith-expr COMMA arg-list 	{ argList = L_pushBack(argList,$1); }
	| arith-expr			  	{ argList = L_pushBack(argList,$1); }
	;

bool-expr:
	arith-expr EQ arith-expr 	{ $$ = new_subtree(_EQ,0,2,$1,$3); }
	| arith-expr NEQ arith-expr { $$ = new_subtree(_NEQ,0,2,$1,$3); }
	| arith-expr LT arith-expr 	{ $$ = new_subtree(_LT,0,2,$1,$3);  }
	| arith-expr LE arith-expr 	{ $$ = new_subtree(_LE,0,2,$1,$3); }
	| arith-expr GT arith-expr 	{ $$ = new_subtree(_GT,0,2,$1,$3);  }
	| arith-expr GE arith-expr 	{ $$ = new_subtree(_GE,0,2,$1,$3); }
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


List* add_children_from_stack(Tree* parent, List* stack){
	Tree* t = NULL;

	do{
		stack = L_popBack(stack,&t);

		if(t != NULL)
			add_child(parent,t);

	}while(stack != NULL);

	return stack;
}

int check_var_rdcl(int sym_table_pos){
	if(sym_table_pos == -1)
		return add_var(symbols,idRead,yylineno,currentScope);
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

	//print_func_table(functions);

	if(func_table_pos == -1)
		return add_func(functions,tmpStr,arity,yylineno);
	else{
		printf(FUNC_RDCL_ERROR_MSG,yylineno,tmpStr,get_func_line(functions,func_table_pos));
		exit(1);
		return 0;
	}
}

void check_func_ndcl(int func_table_pos, int arity){

	//print_sym_table(symbols);
	//printf("\n");
	//print_func_table(functions);

	if(func_table_pos == -1){
		printf(FUNC_NDCL_ERROR_MSG,yylineno,tmpStr);
		exit(1);
	}else{
		int declaredArity = get_func_arity(functions, func_table_pos);

		if(declaredArity != arity){
			printf(FUNC_NARG_ERROR_MSG,yylineno,tmpStr,arity,declaredArity);
			exit(1);
		}
	}
}


int main() {
 // yydebug = 1; // Enter debug mode.

	literals = create_lit_table();
 	symbols = create_sym_table();
	functions = create_func_table();

	if (yyparse() == 0){
		//print_dot(ast);
		printf("PARSE SUCESSFUL!\n\n");
		print_lit_table(literals);
		printf("\n\n");
		print_sym_table(symbols);
		printf("\n\n");
		print_func_table(functions);
	}


	free_lit_table(literals);
	free_sym_table(symbols);
	free_func_table(functions);


  	return 0;
}
