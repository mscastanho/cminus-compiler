#ifndef STACK_H
#define STACK_H

struct stackNode;

typedef struct stackNode Stack;

Stack* stack_new(ValPtr i);
Stack* stack_push(Stack* s, ValPtr i);
Stack* stack_pop (Stack* s, ValPtr *r);

#endif
