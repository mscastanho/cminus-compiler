#ifndef TREE_H
#define TREE_H

typedef enum tp {
	FUNC_LIST,
	FUNC_DECL,
	FUNC_HEADER,
	FUNC_BODY,
	VAR_LIST,
	BLOCK,
	PARAMS,
	CVAR,
	SVAR,
	_INT,
	_VOID,
	_ID,
	_NUM,
	_IF,
	_WHILE,
	_RETURN,
	_INPUT,
	_OUTPUT,
	_STRING,
	_WRITE,
	USER_FUNC,
	ARG_LIST,
	_ASSIGN,
	_EQ,
	_NEQ,
	_LT,
	_LE,
	_GT,
	_GE,
	_PLUS,
	_MINUS,
	_TIMES,
	_OVER
} nodeType;

struct node; // Opaque structure to ensure encapsulation.

typedef struct node Tree;

Tree* new_node(nodeType type, int data);

int get_tree_data(Tree* t);

void set_tree_data(Tree* t, int data);

nodeType get_tree_type(Tree* t);

void set_tree_type(Tree *t, nodeType type);

int get_children_number(Tree *t);

Tree* get_child(Tree* t, int i);

void add_child(Tree *parent, Tree *child);

Tree* new_subtree(nodeType type, int data, int child_count, ...);

void print_tree(Tree *tree);
void print_dot(Tree *tree);
void print_node(Tree *node, int level);

void free_tree(Tree *tree);

#endif
