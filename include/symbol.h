#ifndef SYMBOL_H
#define SYMBOL_H

#include <tree.h>

typedef struct symbol_environment_s *symbol_environment_t;
typedef struct symbol_s *symbol_t;
typedef struct symbol_level_s *symbol_level_t;

typedef enum { VARIABLE, FUNCTION, FUNCTION_REC } symbol_type_t;


symbol_t             symbol_create    (const char *, symbol_type_t, tree_t);
void                 symbol_destroy   (symbol_t);
symbol_type_t  symbol_get_type  (const symbol_t);
tree_t symbol_get_value (const symbol_t);
void symbol_set_value (symbol_t s, tree_t value);

symbol_environment_t symbol_environment_create (void);
void symbol_environment_destroy (symbol_environment_t se);
void symbol_environment_increase_level (symbol_environment_t se);
void symbol_environment_decrease_level (symbol_environment_t se);
void symbol_environment_add (symbol_environment_t se, symbol_t s);
symbol_t symbol_environment_get (symbol_environment_t se, const char *s_name);

symbol_level_t symbol_level_create (void);
void symbol_level_destroy (symbol_level_t sl);
void symbol_level_add (symbol_level_t sl, symbol_t s);
symbol_t symbol_level_lookup (symbol_level_t sl, char *s_name);

#endif
