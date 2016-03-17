#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <parser.h>

struct tree_t;
struct attributes;
typedef struct tree_t *tree;
typedef struct attributes_t *attributes;

enum type {tree, word};        /* typage des nœuds: permet de savoir si un nœud construit un arbre 
                                  ou s'il s'agit simplement de texte */


tree tree_create (char *label, bool nullary, bool space, enum type tp, attributes attr, tree daughters, tree right);
void tree_add_brother (tree t, tree brother);
attributes attributes_create (char *key, char *value);
void attributes_add_tolist (attributes att, attributes new_first);
void transcript_to_XML (char *name);
