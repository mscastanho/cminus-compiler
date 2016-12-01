#include <stdio.h>
#include "interpreter.h"
#include "tree.h"
#include "stack.h"
#include "tables.h"

Stack* stack;
//extern SymTable *vt;

// Forward declaration
void rec_run_ast(Tree *ast);

/*void store(Tree* node, int val){
  int pos = get_data(node);
  set_currVal(vt,pos,val);
}*/

void run_stmt_seq(Tree* node){

}

void run_func_list(Tree* node){

}

void run_func_decl(Tree* node){

}

void run_func_header(Tree* node){

}

void run_param_list(Tree* node){

}

void run_func_body(Tree* node){

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

}

void run_output(Tree* node){

}

void run_write(Tree* node){

  //TODO: not sure if this is right
  //int pos = get_tree_data(get_child(node,0));

  //TODO: implement get_currVal() of tables.c
  //printf("%d",get_currVal(vt,pos));
}

void run_read(Tree* node){
  //stdin = fopen(ctermid(NULL), "r");
  /*int temp;

  scanf("%d",&temp);

  store(get_child(node, 0),temp);
  */
}

void run_assign(Tree* node){
  int result;

  rec_run_ast(get_child(node,1));
  stack = stack_pop(stack,&result);

  //store(get_child(node,0),result);
}

void run_num(Tree* node){
  stack = stack_push(stack, get_tree_data(node));
}

void run_svar(Tree* node){
  //int pos = get_data(node);

  //stack = stack_push(stack,get_currVal(vt,pos));
}

void run_cvar(Tree* node){

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
    printf("Root: %p\n", ast);

}
