#include <stdlib.h>
#include <stdio.h>
#include "stack.h"

struct stackNode {
	int value;
	Stack* next;
};

Stack* stack_new(int i){
	Stack* s = (Stack*) malloc(sizeof(Stack));
	s->value = i;
	s->next = NULL;

	return s;
}

// This adds an element to the end of the list
Stack* stack_push(Stack* s, int i){

	if(s == NULL)
		return stack_new(i);

	Stack* n = stack_new(i);
	n->next = s;

	return n;
}

Stack* stack_pop(Stack* s, int *r){

	if(s == NULL)
		return s;

	Stack* ns = s->next;
	s->next = NULL;

	*r = s->value;

	free(s);

	return ns;
}
