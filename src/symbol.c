#include <stdlib.h>
#include <symbol.h>

#define SYMBOL_TABLE_DEFAULT_SIZE 10
#define SYMBOL_TABLE_LEVEL_DEFAULT_SIZE 10

struct symbol_s {
	const char const *name;
	symbol_type_t type;
	tree_t value;
}; 

symbol_t symbol_create (const char const *name, symbol_type_t type, tree_t value) {
	symbol_t s = malloc(sizeof (*s));
	s->name = strdup(name);
	s->type = type;
	s->value = value;
	return s;
}

void symbol_destroy (symbol_t s) {
	free(s->name);
	tree_destroy(s->value);
	free(s);
}

symbol_type_t symbol_get_type (const symbol_t s) {
	return s->type;
}

const symbol_value_t symbol_get_value (const symbol_t symbol) {
	return s->value;
}

struct symbol_table_s {
	symbol_table_level *table;
	unsigned short level;
	int size;
};

typedef struct symbol_table_level_s {
	symbol_t *sl;
	int nb_elem;
	int size;
} *symbol_table_level_t;

symbol_table_t symbol_table_create (void) {
	symbol_table_s st = malloc(sizeof (*st));
	st->table = malloc(SYMBOL_TABLE_DEFAULT_SIZE * sizeof (symbol_table_level_t *));
	st->table->sl = malloc(SYMBOL_TABLE_LEVEL_DEFAULT_SIZE * sizeof (symbol_t *));
	st->table->nb_elem = SYMBOL_TABLE_LEVEL_DEFAULT_SIZE;
	st->table->size = SYMBOL_TABLE_LEVEL_DEFAULT_SIZE;
	st->level = 0;
	st->size = SYMBOL_TABLE_DEFAULT_SIZE;
	return st;
}


void symbol_table_level_destroy (symbol_table_level_t sl) {
	for (int i = 0 ; i < sl->nb_elem ; i++) {
		symbol_destroy(sl->sl[i]);
	}
}

void symbol_table_destroy (symbol_table_t st) {
	for (int i = st->level ; i > -1 ; i--) {
		symbol_table_level_destroy(st->table[i]);
	}
	free(st);
}

void symbol_table_increase_level (symbol_table_t st) {

}

void symbol_table_decrease_level (symbol_table_t st) {
	if (st->level > 0) {
		symbol_table_level_destroy(st->table[st->level]);
		st->level--;
	}
}

void symbol_table_add (symbol_table_t st, symbol_t s) {
	if (st->nb_elem == st->size) {
		st->size *= 2;
		realloc(st->sl, st->size * sizeof (symbol_table_level *)); 
	}
	st->table[st->level] = s;
	st->level ++;
	st->nb_elem ++;
}


const symbol_t symbol_table_get (symbol_table_t st, const char const * name){
	for (int i = st->level ; i > -1 ; i--) {
		for (int j = 0 ; j < st->nb_elem ; j++) {
			if (st->table[i]->sl[j]->name == name) {
				return st->table[i]->sl[j];
			}
		}
	}
}
