#include <stdlib.h>
#include <stdio.h>
#include "tree.h"
#include "stack.h"

struct stackNode {
	Tree* value;
	Stack* next;
};

Stack* S_new(Tree* t){
	Stack* s = (Stack*) malloc(sizeof(Stack));
	s->value = t;
	s->next = NULL;

	return s;
}

// This adds an element to the end of the sueue 
Stack* S_addNode(Stack* s, Tree* t){
		
	if(s == NULL)
		return S_new(t);

	Stack* it = s;

	while(it->next != NULL)
		it = it->next;

	Stack* n = S_new(t);
	it->next = n;

	return s;
}

int S_getSize(Stack* s){
	
	if(s == NULL)
		return 0;

	Stack* it = s;
	int cnt = 1;

	while(it->next != NULL){
		cnt++;		
		it = it->next;		
	}

	return cnt;
}

// This removes an element from the beginning of the sueue
// and returns it to p
Stack* S_removeNode(Stack* s, Tree** r){

	// from beginning
	/*if(s == NULL)
		return s;

	Stack* ns = s->next;
	s->next = NULL;

	*r = s->value;
	
	S_free(s);

	return ns;*/

	//from end
	if(s == NULL)
		return s;

	if(s->next == NULL){
		*r = s->value;
		S_free(s);
		return NULL;
	}

	Stack* aux = NULL;
	Stack* it = s;

	while(it->next != NULL){
		aux = it;
		it = it->next;	
	}

	aux->next = NULL;
	
	*r = it->value;
	
	S_free(it);

	return s;
}

void S_print(Stack* s){

	if(s == NULL)
		printf("Empty sueue.\n");
	else{

		Stack* it;

		for(it = s ; it != NULL ; it = it->next){
			printf("[%p: next=%p value=%p] -> ",it,it->next,it->value);
		}
		
		printf("\n");
	}
}

void S_free(Stack* s){
	if(s != NULL){
		Stack *it, *aux;

		for(it = s ; it != NULL ; it = aux){
			aux = it->next;			
			free(s);
		}
	}
}


