#ifndef INTERPRETER_H_
#define INTERPRETER_H_

#include "tree.h"

typedef union valPtr {
  int val;
  int* ptr;
}ValPtr;

typedef struct frame Frame;
void run_ast(Tree *ast);

#endif
