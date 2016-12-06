#ifndef INTERPRETER_H_
#define INTERPRETER_H_

#include "tree.h"

typedef struct frame Frame;
void run_ast(Tree *ast);

#endif
