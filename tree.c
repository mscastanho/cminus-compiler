
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256
#define MAX_STRING_SIZE 64

struct node {
    nodeType type;
    int data;
    int count;
    Tree* child[CHILDREN_LIMIT];
};

Tree* new_node(nodeType type, int data) {
    Tree* node = malloc(sizeof * node);
    node->type = type;
    node->count = 0;
    for (int i = 0; i < CHILDREN_LIMIT; i++) {
        node->child[i] = NULL;
    }
    return node;
}

void add_child(Tree *parent, Tree *child) {
    if (parent->count == CHILDREN_LIMIT) {
        fprintf(stderr, "Cannot add another child!\n");
        exit(1);
    }
    parent->child[parent->count] = child;
    parent->count++;
}

Tree* new_subtree(nodeType type, int data, int child_count, ...) {
    if (child_count > CHILDREN_LIMIT) {
        fprintf(stderr, "Too many children as arguments!\n");
        exit(1);
    }

    Tree* node = new_node(type,data);
    va_list ap;
    va_start(ap, child_count);
    for (int i = 0; i < child_count; i++) {
        add_child(node, va_arg(ap, Tree*));
    }
    va_end(ap);
    return node;
}

void print_node(Tree *node, int level) {
    printf("%d: Node -- Addr: %p -- Type: %d -- Count: %d\n",
           level, node, node->type, node->count);
    for (int i = 0; i < node->count; i++) {
        print_node(node->child[i], level+1);
    }
}

void print_tree(Tree *tree) {
    print_node(tree, 0);
}

void free_tree(Tree *tree) {
    for (int i = 0; i < tree->count; i++) {
        free_tree(tree->child[i]);
    }
    free(tree);
}

void type2str(nodeType type, int data, char* str){

	char aux[MAX_STRING_SIZE];

	switch(type){
		case PROGRAM: 
					strcpy(str,"program");
					break;
		case FUNC_DECL:
					strcpy(str,"func-decl");
					break;
		case FUNC_HEADER:
					strcpy(str,"func-header");
					break;
		case FUNC_BODY:
					strcpy(str,"func-body");
					break;
		case VAR_LIST:
					strcpy(str,"var-list");
					break;
		case BLOCK:
					strcpy(str,"block");
					break;
		case PARAMS:
					strcpy(str,"params");
					break;
		case CVAR:
					sprintf(aux,"cvar,%d",data);
					strcpy(str,aux);
					break;
		case SVAR:
					sprintf(aux,"svar,%d",data);
					strcpy(str,aux);
					break;
		case _INT:
					strcpy(str,"int");
					break;
		case _VOID:
					strcpy(str,"void");
					break;
		case _ID:
					sprintf(aux,"id,%d",data);
					strcpy(str,aux);
					break;
		case _NUM:
					sprintf(aux,"num,%d",data);
					strcpy(str,aux);
					break;
		case _IF:
					strcpy(str,"if");
					break;
		case _WHILE:
					strcpy(str,"while");
					break;
		case _RETURN:
					strcpy(str,"return");
					break;
		case _INPUT:
					strcpy(str,"input");
					break;
		case _OUTPUT:
					strcpy(str,"output");
					break;
		case _STRING:
					sprintf(aux,"string,%d",data);
					strcpy(str,aux);
					break;
		case _WRITE:
					strcpy(str,"write");
					break;
		case USER_FUNC:
					sprintf(aux,"fcall,%d",data);
					strcpy(str,aux);
					break;
		case ARG_LIST:
					strcpy(str,"arg-list");
					break;
		case _ASSIGN:
					strcpy(str,"=");
					break;
		case _EQ:
					strcpy(str,"==");
					break;
		case _NEQ:
					strcpy(str,"!=");
					break;
		case _LT:
					strcpy(str,"<");
					break;
		case _LE:
					strcpy(str,"<=");
					break;
		case _GT:
					strcpy(str,">");
					break;
		case _GE:
					strcpy(str,">=");
					break;
		case _PLUS:
					strcpy(str,"+");
					break;
		case _MINUS:
					strcpy(str,"-");
					break;
		case _TIMES:
					strcpy(str,"*");
					break;
		case _OVER:
					strcpy(str,"/");
					break;
	}
}

// Dot output.

int nr;

int print_node_dot(Tree *node) {
    int my_nr = nr++;
	 char text[MAX_STRING_SIZE];

	 type2str(node->type,node->data,text);

	 printf("node%d[label=\"%s\"];\n", my_nr, text);			

    for (int i = 0; i < node->count; i++) {
        int child_nr = print_node_dot(node->child[i]);
        printf("node%d -> node%d;\n", my_nr, child_nr);
    }
    return my_nr;
}

void print_dot(Tree *tree) {
    nr = 0;
    printf("digraph {\ngraph [ordering=\"out\"];\n");
    print_node_dot(tree);
    printf("}\n");
}
