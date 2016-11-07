#ifndef LIST_H
#define LIST_H

struct listNode;

typedef struct listNode List;

List* L_new(Tree* t);

// This adds an element to the list
List* L_pushBack(List* q, Tree* t);

// Returns the current list size
int L_getSize(List* q);

// This removes an element from the list
// and saves its value in r
List* L_popBack(List* q, Tree** r);

// This removes an element from the beginning of the list
// and saves its value in r
List* L_popFront (List* s, Tree** r);

void L_print(List* q);

void L_free(List* q);

#endif
