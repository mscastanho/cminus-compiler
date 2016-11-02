#include <stdlib.h>
#include <stdio.h>
#include "tree.h"
#include "queue.h"

struct queueNode {
	Tree* value;
	Queue* next;
};

Queue* Q_new(Tree* t){
	Queue* q = (Queue*) malloc(sizeof(Queue));
	q->value = t;
	q->next = NULL;

	return q;
}

// This adds an element to the end of the queue 
Queue* Q_addNode(Queue* q, Tree* t){
		
	if(q == NULL)
		return Q_new(t);

	Queue* it = q;

	while(it->next != NULL)
		it = it->next;

	Queue* n = Q_new(t);
	it->next = n;

	return q;
}

// This removes an element from the beginning of the queue
// and returns it to p
Queue* Q_removeNode(Queue* q, Tree** r){

	if(q == NULL)
		return q;

	Queue* nq = q->next;
	q->next = NULL;

	*r = q->value;
	
	Q_free(q);

	return nq;
}

void Q_print(Queue* q){

	if(q == NULL)
		printf("Empty queue.\n");
	else{

		Queue* it;

		for(it = q ; it != NULL ; it = it->next){
			printf("[%p: next=%p value=%p] -> ",it,it->next,it->value);
		}
		
		printf("\n");
	}
}

void Q_free(Queue* q){
	if(q != NULL){
		Queue *it, *aux;

		for(it = q ; it != NULL ; it = aux){
			aux = it->next;			
			free(q);
		}
	}
}


