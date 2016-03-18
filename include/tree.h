#ifndef _TREE_H
#define _TREE_H

typedef struct tree_t *tree;
typedef struct attributes_t *attributes;
enum type {tree, word};        /* typage des nœuds: permet de savoir si un nœud construit un arbre 
                                  ou s'il s'agit simplement de texte */


tree tree_create (char *label, bool nullary, bool space, enum type tp, attributes attr, tree daughters, tree right);
attributes attributes_create (char *key, char *value);
void attributes_add_tolist (attributes att, attributes att_list);
void tree_add_brother (tree t, tree brother);

#endif