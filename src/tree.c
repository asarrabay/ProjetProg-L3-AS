#include <tree.h>
struct attributes_t {
    char *key;                /* nom de l'attribut */
    char *value;              /* valeur de l'attribut */
    attributes next;          /* attribut suivant */
};



struct tree_t {
    char *label;              /* étiquette du nœud */
    bool nullary;             /* nœud vide, par exemple <br/> */
    bool space;               /* nœud suivi d'un espace */
    enum type tp;             /* type du nœud. nullary doit être true s tp vaut word */
    attributes attr;          /* attributs du nœud */
    tree daughters;           /* fils gauche, qui doit être NULL si nullary est true */
    tree right;               /* frère droit */
};



tree tree_create (char *label, bool nullary, bool space, enum type tp, attributes attr, tree daughters, tree right) {
    tree t = malloc(sizeof (struct tree_t));

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



void tree_add_brother (tree t, tree brother) {
    if (brother == NULL)
        return;
    
    t->right = brother;
}
