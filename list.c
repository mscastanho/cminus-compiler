#include <stdlib.h>
#include <stdio.h>
#include "tree.h"
#include "list.h"

struct listNode {
	Tree* value;
	List* next;
};

List* L_new(Tree* t){
	List* s = (List*) malloc(sizeof(List));
	s->value = t;
	s->next = NULL;

	return s;
}

// This adds an element to the end of the list
List* L_pushBack(List* s, Tree* t){

	if(s == NULL)
		return L_new(t);

	List* it = s;

	while(it->next != NULL)
		it = it->next;

	List* n = L_new(t);
	it->next = n;

	return s;
}

int L_getSize(List* s){

	if(s == NULL)
		return 0;

	List* it = s;
	int cnt = 1;

	while(it->next != NULL){
		cnt++;
		it = it->next;
	}

	return cnt;
}

// This removes an element from the beginning of the sueue
// and returns it to p
List* L_popBack(List* s, Tree** r){

	//from end
	if(s == NULL)
		return s;

	if(s->next == NULL){
		*r = s->value;
		L_free(s);
		return NULL;
	}

	List* aux = NULL;
	List* it = s;

	while(it->next != NULL){
		aux = it;
		it = it->next;
	}

	aux->next = NULL;

	*r = it->value;

	L_free(it);

	return s;
}

List* L_popFront (List* s, Tree** r){

	if(s == NULL)
		return s;

	List* ns = s->next;
	s->next = NULL;

	*r = s->value;

	L_free(s);

	return ns;
}

void L_print(List* s){

	if(s == NULL)
		printf("Empty sueue.\n");
	else{

		List* it;

		for(it = s ; it != NULL ; it = it->next){
			printf("[%p: next=%p value=%p] -> ",it,it->next,it->value);
		}

		printf("\n");
	}
}

void L_free(List* s){
	if(s != NULL){
		List *it, *aux;

		for(it = s ; it != NULL ; it = aux){
			aux = it->next;
			free(s);
		}
	}
}
