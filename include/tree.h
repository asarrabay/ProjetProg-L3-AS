#ifndef TREE_H
#define TREE_H

#include <stdbool.h>

typedef struct tree_s *tree_t;
typedef struct attributes_s *attributes_t;

enum tree_type_e { TREE, WORD };

extern tree_t  tree_create      (char *, bool, bool, enum tree_type_e, attributes_t, tree_t, tree_t);
extern void    tree_destroy     (tree_t);
extern tree_t  tree_add_brother (tree_t, tree_t);
extern void    tree_to_xml      (tree_t, FILE *);

extern attributes_t attributes_create    (char *, tree_t);
extern void         attributes_destroy   (attributes_t);
extern attributes_t attributes_add_ahead (attributes_t, attributes_t);
extern void         attributes_to_xml    (attributes_t, FILE *);

#endif
