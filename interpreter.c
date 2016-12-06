#include <stdio.h>
#include <stdlib.h>
#include "interpreter.h"
#include "tree.h"
#include "stack.h"
#include "tables.h"
#include "string.h"

#define MAX_NUMBER_FRAMES 1024
extern LitTable* literals;
extern SymTable* symbols;
extern FuncTable* functions;
struct frame; // forward reference

Stack* stack;
Frame* frames[MAX_NUMBER_FRAMES];
int frames_idx = -1;

// S = Simple ; C = Array
typedef enum vt {S,C} varType;

// Pair to store position in var table and current val
typedef struct pair{
  int pos;
  int size;
  //int val; //val in case of svar
  //int* ptr; //ptr to structure in case of cvar
  ValPtr value; //Hold either an int or a pointer to an int (CVAR)
  varType type;
} VarPair;

struct frame {
  Tree* func_ptr;
  int func_idx;
  int nArgs;
  VarPair* args;
  int nVars;
  VarPair* vars;
};

void store_frame(Frame* f){
  frames_idx = (++frames_idx) % MAX_NUMBER_FRAMES;

  frames[frames_idx] = f;

  printf("New frame! -> frames_idx = %d\n",frames_idx);
}

void delete_last_frame(){
  frames_idx--;
}

Frame* get_last_frame(){
  return frames[frames_idx];
}

// Forward declaration
void rec_run_ast(Tree *ast);

//index is to be used in case of cvar
//should be 0 otherwise
/*void store(Tree* node, int val){
  int pos = get_tree_data(node);

  if(get_tree_type(node) == CVAR){
    int index;

    //Execute child to get index
    rec_run_ast(get_child(node,0));
    stack = stack_pop(stack,&index);

    set_cvar_currVal(symbols,pos,index,val);
  }else
    set_svar_currVal(symbols,pos,val);
}*/

void store(Tree* node, int val){


  int pos = get_tree_data(node);
  Frame* f = get_last_frame();

  /*if(get_tree_type(node) == CVAR){
    //Get index from stack
    rec_run_ast(get_child(node,0));
    stack = stack_pop(stack,&index);
  }*/

  //Check if it is one of the arguments
  for(int i = 0 ; i < f->nArgs ; i++){
    if(pos == f->args[i].pos){

      if(f->args[i].type == S)
        f->args[i].value.val = val;
      else{ //array
        ValPtr index;
        rec_run_ast(get_child(node,0));
        stack = stack_pop(stack,&index);

        // In this case args[i].value has a pointer to the array
        f->args[i].value.ptr[index.val] = val;
      }
      //printf(" Storing: %s = %d \n",get_name(symbols,pos),val);
      return;
    }
  }

  //Check if it is one of the variables
  for(int i = 0 ; i < f->nVars ; i++){
    if(pos == f->vars[i].pos){

      if(f->vars[i].type == S)
        f->vars[i].value.val = val;
      else{ //array
        ValPtr index;
        rec_run_ast(get_child(node,0));
        stack = stack_pop(stack,&index);

        // In this case args[i].value has a pointer to the array
        f->vars[i].value.ptr[index.val] = val;
      }
      //printf(" Storing: %s = %d \n",get_name(symbols,pos),val);
      return;
    }
  }

  printf("Could not store value.\n");
  exit(1);
}

int load(Tree* node){
  int pos = get_tree_data(node);
  Frame* f = get_last_frame();

  //Check if it is one of the arguments
  for(int i = 0 ; i < f->nArgs ; i++){
    if(pos == f->args[i].pos){
      if(f->args[i].type == S){
          return f->args[i].value.val;
      }else{
        // array
        ValPtr index;
        rec_run_ast(get_child(node,0));
        stack = stack_pop(stack,&index);

        return f->args[i].value.ptr[index];

      }
    }
  }

  //Check if it is one of the variables
  for(int i = 0 ; i < f->nVars ; i++){
    if(pos == f->vars[i].pos){
      if(f->vars[i].type == S){
          return f->vars[i].value.val;
      }else{
        // array
        int index;
        rec_run_ast(get_child(node,0));
        stack = stack_pop(stack,&index);

        return f->vars[i].value.ptr[index];
  }

  printf("Could not load value.\n");
  exit(1);
}

void run_func_list(Tree* node){

  int cnt = get_children_number(node);
  Tree* main_node = NULL;

  for(int i = 0 ; i < cnt ; i++){

    Tree* func_decl_node = get_child(node,i);

    // Get index at functions table
    int ftPos = get_tree_data(func_decl_node);

    // Save pointer to main
    if(ftPos != -1){
      char* func_name = get_func_name(functions,ftPos);

      if(!strcmp("main",func_name))
        main_node = func_decl_node;
    }else
      printf("ERROR AT INTERPRETER.C:RUN_FUNC_LIST()\n");
  }
    if(main_node != NULL)
      rec_run_ast(main_node);
    else
      printf("Could not find main function.\n");
}

void run_func_decl(Tree* node){

  //printf("Running function: %s\n",get_func_name(functions,get_tree_data(node)));

  // Create function frame
  Frame* f = (Frame*) malloc (sizeof(Frame));
  f->func_ptr = node;
  f->func_idx = get_tree_data(node);
  f->nArgs = get_func_arity(functions,f->func_idx);
  f->args = (VarPair*) malloc (f->nArgs*sizeof(VarPair));
  //f->vars will be set later
  //f->nVars will be set later

  store_frame(f);

  //Execute function header
  rec_run_ast(get_child(node,0));

  //Execute function body
  rec_run_ast(get_child(node,1));
}

void run_func_header(Tree* node){

  // Execute parameter list
  rec_run_ast(get_child(node,2));
}

void run_param_list(Tree* node){

  Frame* f = get_last_frame();

  //printf("With parameters: ");

  for(int i = get_children_number(node) - 1 ; i >= 0  ; i--){
    int index;

    Tree* child = get_child(node,i);

    // Save arg positions
    f->args[i].pos = get_tree_data(child);

    // Get arg values from stack and save in local memory
    // If the argument is an array, a point to it's structure
    // will be passed in the stack
    int arg;
    stack = stack_pop(stack,&arg);
    f->args[i].value.val = arg;

    //printf(" %s = %d ",get_name(symbols,f->args[i].pos),arg);

  }

  //printf("\n");

}

void run_func_body(Tree* node){

  // Run var declaration
  rec_run_ast(get_child(node,0));

  // Run statements
  rec_run_ast(get_child(node,1));
}

void run_var_list(Tree* node){

  //Get current function frame
  Frame *f = get_last_frame();

  f->nVars = get_children_number(node);
  f->vars = (VarPair*) malloc (f->nVars*sizeof(VarPair));


  //printf("Initializing the following variables:\n");
  // Initialize vars with pos and current value
  for(int i = 0 ; i < get_children_number(node) ; i++){
    int size = 1;

    Tree* child = get_child(node,i);

    f->vars[i].pos = get_tree_data(child);

    if(get_tree_type(child) == CVAR){
      // Get array size
      rec_run_ast(get_child(child,0));
      stack = stack_pop(stack,&size);

      // Allocate structure for array
      int* p = (int*) malloc (size*sizeof(int));
      f->vars[i].ptr = (int) p;
      f->vars[i].type = C;
      f->vars[i].val = -1; // trash. not used in case of cvar
    }else{
      f->vars[i].val = 0;
      f->vars[i].type = S;
      f->vars[i].ptr = NULL; // trash. not used in case of svar
    }


    //printf(" %s = %d ",get_name(symbols,f->vars[i].pos),f->vars[i].val);
  }

//  printf("\n\n");
}

void run_block(Tree* node){
  int cnt = get_children_number(node);

  for(int i = 0 ; i < cnt ; i++){
    rec_run_ast(get_child(node, i));
  }
}

void run_input(Tree* node){
  int value;

  scanf("%d",&value);

  stack = stack_push(stack, value);
}

void run_output(Tree* node){

  int value;

  // Execute argument
  rec_run_ast(get_child(node,0));

  // Get value from stack
  stack = stack_pop(stack, &value);

  printf("%d",value);
}

void run_write(Tree* node){

  int ltPos = get_tree_data(get_child(node,0));
  char p,c;
  char string[128];
  strcpy(string,get_literal(literals,ltPos));

  int len = strlen(string);

  for(int i = 0 ; i < len ; i++){
      c = string[i];

      if(c != '\\')
        p = c;
      else if(i < len - 1){
          if(string[i+1] == 'n')
            p = '\n';

          if(string[i+1] == 't')
            p = '\t';

        i++;
      }

      printf("%c",p);
    }
}

void run_read(Tree* node){
  //stdin = fopen(ctermid(NULL), "r");
  int temp;

  scanf("%d",&temp);

  store(get_child(node, 0),temp);
}

void run_assign(Tree* node){
  int result;

  rec_run_ast(get_child(node,1));
  stack = stack_pop(stack,&result);

  store(get_child(node,0),result);
}

void run_num(Tree* node){
  stack = stack_push(stack, get_tree_data(node));
}

void run_svar(Tree* node){

  stack = stack_push(stack,load(node));
}

void run_cvar(Tree* node){

  stack = stack_push(stack,load(node));

}

void run_arith_op(Tree* node){
  int left,right;

  rec_run_ast(get_child(node, 0));
  stack = stack_pop(stack, &left);

  rec_run_ast(get_child(node, 1));
  stack = stack_pop(stack, &right);

  switch(get_tree_type(node)){
    case _PLUS:
      stack = stack_push(stack, left + right);
      break;
    case _MINUS:
      stack = stack_push(stack, left - right);
      break;
    case _TIMES:
      stack = stack_push(stack, left*right);
      break;
    case _OVER:
      stack = stack_push(stack, left/right);
      break;
    default:
      //nothing to do
      break;
  }
}

void run_bool_op(Tree* node){
  int left,right;

  rec_run_ast(get_child(node, 0));
  stack = stack_pop(stack, &left);

  rec_run_ast(get_child(node, 1));
  stack = stack_pop(stack, &right);

  switch(get_tree_type(node)){
    case _EQ:
      stack = stack_push(stack, left == right);
      break;
    case _NEQ:
      stack = stack_push(stack, left != right);
      break;
    case _LT:
      stack = stack_push(stack, left < right);
      break;
    case _LE:
      stack = stack_push(stack, left <= right);
      break;
    case _GT:
      stack = stack_push(stack, left > right);
      break;
    case _GE:
      stack = stack_push(stack, left >= right);
      break;
    default:
      //nothing to do
      break;
  }
}

void run_if(Tree* node){

  int result;

  // run bool-exp
  rec_run_ast(get_child(node,0));
  // result at stack top
  stack = stack_pop(stack,&result);

  switch(get_children_number(node)){
      case 2:
        if(result == 1)
          rec_run_ast(get_child(node,1));
        break;
      case 3:
        if(result == 1)
          rec_run_ast(get_child(node,1));
        else
          rec_run_ast(get_child(node,2));
  }
}

void run_while(Tree* node){

  int result;

  do{
    // run statements
    rec_run_ast(get_child(node, 1));

    // eval bool-exp
    rec_run_ast(get_child(node,0));
    stack = stack_pop(stack,&result);
  }while(result == 1);

}

void run_user_func(Tree* node){

  int func_idx = get_tree_data(node);

  // Run arguments list
  rec_run_ast(get_child(node,0));

  // Execute function
  rec_run_ast(get_func_ptr(functions,func_idx));

  // Remove frame after execution
  delete_last_frame();
}

void run_arg_list(Tree* node){
  int cnt = get_children_number(node);

  // Evaluate and push arguments to stack
  for(int i = 0 ; i < cnt ; i++ ){
    rec_run_ast(get_child(node,i));
  }
}

void run_return(Tree* node){

  // Stack return value by recursively running argument
  rec_run_ast(get_child(node,0));
}

void rec_run_ast(Tree *ast) {

    char string[16];
    type2str(get_tree_type(ast),0,string);

    //printf("-------> Running node: %s\n",string);

    switch(get_tree_type(ast)){
        case FUNC_LIST:
          run_func_list(ast);
          break;
        case FUNC_DECL:
          run_func_decl(ast);
          break;
        case FUNC_HEADER:
          run_func_header(ast);
          break;
        case PARAMS:
          run_param_list(ast);
          break;
        case FUNC_BODY:
          run_func_body(ast);
          break;
        case VAR_LIST:
          run_var_list(ast);
          break;
        case BLOCK:
          run_block(ast);
          break;
        case _INPUT:
          run_input(ast);
          break;
        case _OUTPUT:
          run_output(ast);
          break;
        case _WRITE:
          run_write(ast);
          break;
        case _ASSIGN:
          run_assign(ast);
          break;
        case _NUM:
          run_num(ast);
          break;
        case SVAR:
          run_svar(ast);
          break;
        case CVAR:
          run_cvar(ast);
          break;
        case _PLUS:
        case _MINUS:
        case _TIMES:
        case _OVER:
          run_arith_op(ast);
          break;
        case _EQ:
        case _NEQ:
        case _LT:
        case _LE:
        case _GT:
        case _GE:
          run_bool_op(ast);
          break;
        case _IF:
          run_if(ast);
          break;
        case _WHILE:
          run_while(ast);
          break;
        case USER_FUNC:
          run_user_func(ast);
          break;
        case ARG_LIST:
          run_arg_list(ast);
          break;
        case _RETURN:
          run_return(ast);
          break;
        default:
          break;
    }
}

void run_ast(Tree *ast) {
    rec_run_ast(ast);
    //free(stack);
}
