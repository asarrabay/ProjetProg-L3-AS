/* Source file for the stack abstract data type (stack.c) implemented with a list */

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "stack.h"

typedef struct chaine_s *chaine_t;


struct stack_s {
    chaine_t p_top;
};
    

struct chaine_s {
    void *data;
    chaine_t p_next;
};
    
    

stack_t stack_create (void) {
    stack_t p_tmp_stack = malloc(sizeof (struct stack_s));
    p_tmp_stack->p_top = NULL;
    
    return p_tmp_stack;
}



void stack_destroy (stack_t s) {
    chaine_t p_tmp_chaine;

    while (!stack_empty(s)) {
        p_tmp_chaine = (s->p_top)->p_next;
        free(s->p_top);
        s->p_top = p_tmp_chaine;
    }
}



void stack_push (stack_t s, void *object) {
    chaine_t p_tmp_chaine = malloc(sizeof (struct chaine_s));

    p_tmp_chaine->data = object;
    p_tmp_chaine->p_next = s->p_top;

    s->p_top = p_tmp_chaine;
}



int stack_empty (stack_t s) {
    return s->p_top == NULL;
}



void * stack_top (stack_t s) {
    if (stack_empty(s)) {
        return NULL;
    }
    
    return (s->p_top)->data;
}



void stack_pop (stack_t s) {
    if (stack_empty(s)) {
        return;
    }

    chaine_t p_tmp_chaine = (s->p_top)->p_next;
    free(s->p_top);
    s->p_top = p_tmp_chaine;
}

