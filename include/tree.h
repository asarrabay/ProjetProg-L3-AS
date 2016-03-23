#ifndef _TREE_H
#define _TREE_H

#include <stdbool.h>

typedef struct tree_s *tree_t;
typedef struct attributes_s *attributes_t;
enum type {tree, word};        /* typage des nœuds: permet de savoir si un nœud construit un arbre 
                                  ou s'il s'agit simplement de texte */

tree_t tree_create (char *label, bool nullary, bool space, enum type tp,
                    attributes_t attr, tree_t daughters, tree_t right);
tree_t tree_add_brother (tree_t t, tree_t brother);

attributes_t attributes_create (char *key, tree_t text);
attributes_t attributes_add_tolist (attributes_t attr_list, attributes_t attr);

#endif
