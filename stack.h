#ifndef STACK_H
#define STACK_H

struct stackNode;

typedef struct stackNode Stack;

Stack* stack_new(int i);
Stack* stack_push(Stack* s, int i);
Stack* stack_pop (Stack* s, int *r);

#endif
