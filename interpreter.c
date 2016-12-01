#include <stdio.h>
#include "interpreter.h"
#include "tree.h"
#include "stack.h"
#include "tables.h"
#include "string.h"

extern LitTable* literals;
extern SymTable* symbols;
extern FuncTable* functions;

Stack* stack;

// Forward declaration
void rec_run_ast(Tree *ast);

//index is to be used in case of cvar
//should be 0 otherwise
void store(Tree* node, int val){
  int pos = get_tree_data(node);

  if(get_tree_type(node) == CVAR){
    int index;

    //Execute child to get index
    rec_run_ast(get_child(node,0));
    stack = stack_pop(stack,&index);

    set_cvar_currVal(symbols,pos,index,val);
  }else
    set_svar_currVal(symbols,pos,val);
}

void run_stmt_seq(Tree* node){

}

void run_func_list(Tree* node){

  int cnt = get_children_number(node);
  Tree* main_node;

  for(int i = 0 ; i < cnt ; i++){

    Tree* func_decl_node = get_child(node,i);

    // Get index at functions table
    int ftPos = get_tree_data(func_decl_node);

    // Set function pointer
    set_func_ptr(functions,ftPos,func_decl_node);

    // Save pointer to main
    if(ftPos != -1){
      char* func_name = get_func_name(functions,ftPos);

      if(!strcmp("main",func_name))
        main_node = get_func_ptr(functions,ftPos);
    }else
      printf("ERROR AT INTERPRETER.C:RUN_FUNC_LIST()\n");
  }

  rec_run_ast(main_node);
}

void run_func_decl(Tree* node){
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

}

void run_func_body(Tree* node){

  // Run var declaration
  rec_run_ast(get_child(node,0));

  // Run statements
  rec_run_ast(get_child(node,1));
}

void run_var_list(Tree* node){

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
  //TODO: Use strtok to split string by \n
  printf("%s",get_literal(literals,ltPos));
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
  int pos = get_tree_data(node);

  stack = stack_push(stack,get_svar_currVal(symbols,pos));
}

void run_cvar(Tree* node){

  int index,pos;

  // Execute child to know which position to access
  rec_run_ast(get_child(node,0));

  // Get index from stack
  stack = stack_pop(stack, &index);

  pos = get_tree_data(node);

  stack = stack_push(stack,get_cvar_currVal(symbols,pos,index));

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
    rec_run_ast(get_child(node, 0));

    // eval bool-exp
    rec_run_ast(get_child(node,1));
    stack = stack_pop(stack,&result);
  }while(result == 1);

}

void run_user_func(Tree* node){

}

void run_arg_list(Tree* node){

}

void rec_run_ast(Tree *ast) {

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
        default:
          break;
    }
}

void run_ast(Tree *ast) {
    rec_run_ast(ast);
    //free(stack);
}
