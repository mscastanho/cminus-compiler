#ifndef STACK_H
#define STACK_H

struct stackNode;

typedef struct stackNode Stack;

Stack* S_new(Tree* t);

// This adds an element to the stack 
Stack* S_addNode(Stack* q, Tree* t);

// Returns the current stack size
int S_getSize(Stack* q);

// This removes an element from the stack
// and returns its value to r
Stack* S_removeNode(Stack* q, Tree** r);

void S_print(Stack* q);

void S_free(Stack* q);

#endif
