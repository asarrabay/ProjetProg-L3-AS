/* Header file for the stack abstract data type (stack.h) */
#ifndef STACK_H
#define STACK_H 

struct stack_s;

typedef struct stack_s *stack_t;

/* create an empty stack */
extern stack_t stack_create(void);

/* destroy a stack */
extern void stack_destroy(stack_t s);

/* push an object on a stack */
extern void stack_push(stack_t s, void *object);

/* return true if and only if the stack is empty */
extern int stack_empty(stack_t s);

/* return the top element of the stack.
   The stack must not be empty (as reported by stack_empty()) */
extern void * stack_top(stack_t s);

/* pop an element off of the stack.
   The stack must not be empty (as reported by stack_empty()) */
extern void stack_pop(stack_t s);

#endif
