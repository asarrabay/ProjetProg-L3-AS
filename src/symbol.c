#include <stdlib.h>
#include <symbol.h>
#include <stack.h>


/* Un environnement de symbole est représenté par une pile
 * Chaque élement de la pile est un niveau d'environnement
 * Chaque niveau d'environnement est représenté par une liste chaînée
 * Les variables les plus locales se trouvent au sommet de la pile */
struct symbol_environment_s {
    stack_t stack_level;
};



/* Un symbole est associé à un niveau d'environnement
 * Il est stocké dans une liste correspondant à ce niveau */
typedef struct symbol_level_s {
    symbol_t first;
    symbol_t last;
} *symbol_level_t;



/* Un symbole a un nom, un type, une valeur et un pointeur vers le symbole suivant (chainon de file) */
struct symbol_s {
    const char *s_name;
    symbol_type_t type;
    tree_t value;
    symbol_t next;
}; 


/* SYMBOL_T */

symbol_t symbol_create (const char *s_name, symbol_type_t type, tree_t value, symbol_level_t level) {
    symbol_t s = malloc(sizeof (struct symbol_s));
    s->s_name = strdup(name);
    s->type = type;
    s->value = value;
    s->next = NULL;
    
    return s;
}



void symbol_destroy (symbol_t s) {
    free(s->name);
    tree_destroy(s->value);
    free(s);
}



const symbol_type_t symbol_get_type (const symbol_t s) {
	return s->type;
}



const tree_t symbol_get_value (const symbol_t symbol) {
	return s->value;
}



void symbol_set_value (symbol_t s, tree_t value) {
    s->value = value;
}


/* SYMBOL_ENVIRONMENT */

symbol_environment_t symbol_environment_create (void) {
    symbol_environment_t se = malloc(sizeof (struct symbol_environment_s));
    se->stack_level = stack_create();
    
    return st;
}



void symbol_environment_destroy (symbol_environment_t se) {
    symbol_level_t key;

    while (!stack_empty(se->stack_level)) {
        key = (symbol_level_t) stack_top(se->stack_level);
        symbol_level_destroy(key);
        stack_pop(se->stack_level);
    }
    
    stack_destroy(se->stack_level);
    free(se);
}



void symbol_environment_increase_level (symbol_environment_t se) {
    symbol_level_t sl = symbol_level_create();
    stack_push(se>stack_level, (void *) sl);
}



void symbol_environment_decrease_level (symbol_environment_t se) {
    symbol_level_t sl = (symbol_level_t) stack_top(se->stack_level);
    symbol_level_destroy(sl);
    stack_pop(se->stack_level);
}



void symbol_environment_add (symbol_environment_t se, symbol_t s) {
    if (stack_empty(se->stack_level))
        symbol_environment_increase_level(se);

    symbol_level_t sl = (symbol_level_t) stack_top(se->stack_level);
    symbol_level_add(sl, s);
}



/* On parcourt chaque niveau de la pile à la recherche du symbole 
 * On parcourtt du plus local au moins local
 * La pile annexe sert à transférer temporairement les élements pendant qu'on parcourt la première */
symbol_t symbol_environment_get (symbol_environment_t se, const char *s_name) {
    symbol_level_t key;
    symbol_t result = NULL;
    stack_t tmp_stack = stack_create();

    while (!stack_empty(se->stack_level)) {
        key = (symbol_level_t) stack_top(se->stack_level);
        result = symbol_level_lookup(key, s_name);

        if (result != NULL)
            break;

        stack_push(tmp_stack, key);
        stack_pop(se->stack_level);
    }

    /* On restaure la pile initiale */
    while (!stack_empty(tmp_stack)) {
        key = (symbol_level_t) stack_top(tmp_stack);
        stack_push(se->stack_level, key);
        stack_pop(tmp_stack);
    }

    stack_destroy(tmp_stack);
    return res;
}



/* SYMBOL_LEVEL */
/* Implémenter un module externe liste si le temps ? */

symbol_level_t symbol_level_create (void) {
    symbol_level_t sl = malloc(sizeof (struct symbol_level_s));
    sl->first = NULL;
    sl->last = NULL;
    
    return sl;
}



void symbol_level_destroy (symbol_level_t sl) {
    symbol_t key = sl->first;

    /* On supprime les éléments de la liste */
    while (key != NULL) {
        symbol_t next = key->next;
        symbol_destroy(key);
        key = next;
    }

    free(sl);
}



void symbol_level_add (symbol_level_t sl, symbol_t s) {
    if (sl->first == NULL)
        sl->first = s;
    else
        sl->last->next = s;
    sl->last = s;
}
    


/* Permet de voir si un symbole est déclaré à un niveau d'environnement
 * Retourne le symbole en question s'il a été trouvé
 * NULL sinon */
symbol_t symbol_level_lookup (symbol_level_t sl, char *s_name) {
    symbol_t key = sl->first;
    
    while (key != NULL) {
        if (!strcmp(key->s_name, s_name))
            return key;
        key = key->next;
    }

    return NULL;
}
    
    
    

    

