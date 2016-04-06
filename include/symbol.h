#ifndef SYMBOL_H
#define SYMBOL_H

#include <tree.h>

typedef struct symbol_table_s *symbol_table_t;
typedef struct symbol_s *symbol_t;

typedef enum { VARIABLE, FUNCTION, FUNCTION_REC } symbol_type_t;

symbol_table_t symbol_table_create  (void);
void           symbol_table_destroy (symbol_table_t);

void           symbol_table_increase_level (symbol_table_t);
void           symbol_table_decrease_level (symbol_table_t);
void           symbol_table_add (symbol_table_t, symbol_t);
const symbol_t symbol_table_get (symbol_table_t, const char const *);

symbol_t             symbol_create    (const char const *, symbol_type_t, tree_t);
void                 symbol_destroy   (symbol_t);
symbol_type_t        symbol_get_type  (const symbol_t);
const symbol_value_t symbol_get_value (const symbol_t);

#endif
