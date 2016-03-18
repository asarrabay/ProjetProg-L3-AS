#include <tree_t.h>
struct attributes_s {
    char *key;                /* nom de l'attribut */
    char *value;              /* valeur de l'attribut */
    attributes next;          /* attribut suivant */
};



struct tree_s {
    char *label;              /* étiquette du nœud */
    bool nullary;             /* nœud vide, par exemple <br/> */
    bool space;               /* nœud suivi d'un espace */
    enum type tp;             /* type du nœud. nullary doit être true s tp vaut word */
    attributes attr;          /* attributs du nœud */
    tree_t daughters;           /* fils gauche, qui doit être NULL si nullary est true */
    tree_t right;               /* frère droit */
};



tree_t tree_create (char *label, bool nullary, bool space, enum type tp, attributes attr, tree_t daughters, tree_t right) {
    tree_t t = malloc(sizeof (struct tree_t));

    t->label     = label;
    t->nullary   = nullary;
    t->space     = space;
    t->tp        = tp;
    t->attr      = attr;
    t->daughters = daughters;
    t->right     = right;

    return t;
}

    

attributes attributes_create (char *key, char *value) {
    attributes attr = malloc(sizeof (struct attributes_t));

    attr->key   = key;
    attr->value = value;
    attr->next  = NULL;

    return attr;
}    



void attributes_add_tolist (attributes att, attributes att_list) {
    if (att_list == NULL)
        return;
    
    att->next = att_list;
}



void tree_add_brother (tree_t t, tree_t brother) {
    if (brother == NULL)
        return;
    
    t->right = brother;
}
