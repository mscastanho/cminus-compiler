#ifndef queue_H
#define queue_H

struct queueNode;

typedef struct queueNode Queue;

Queue* Q_new(Tree* t);

// This adds an element to the end of the queue 
Queue* Q_addNode(Queue* q, Tree* t);

// This removes an element from the beginning of the queue
// and returns it to p
Queue* Q_removeNode(Queue* q, Tree** r);

void Q_print(Queue* q);

void Q_free(Queue* q);

#endif
