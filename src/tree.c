#include <tree.h>



struct attributes_s {
    char *key;                /* nom de l'attribut */
    char *value;              /* valeur de l'attribut */
    attributes_t next;          /* attribut suivant */
};



struct tree_s {
    char *label;              /* étiquette du nœud */
    bool nullary;             /* nœud vide, par exemple <br/> */
    bool space;               /* nœud suivi d'un espace */
    enum type tp;             /* type du nœud. nullary doit être true s tp vaut word */
    attributes_t attr;          /* attributs du nœud */
    tree_t daughters;           /* fils gauche, qui doit être NULL si nullary est true */
    tree_t right;               /* frère droit */
};



tree_t tree_create (char *label, bool nullary, bool space, enum type tp,
                    attributes_t attr, tree_t daughters, tree_t right) {
    
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

    

attributes_t attributes_create (char *key, char *value) {
    attributes_t attr = malloc(sizeof (struct attributes_s));

    attr->key   = key;
    attr->value = value;
    attr->next  = NULL;

    return attr;
}    



attributes_t attributes_add_tolist (attributes_t att, attributes_t att_list) {
    att->next = att_list;
    return att;
}



tree_t tree_add_brother (tree_t t, tree_t brother) {
    if (t == NULL)
        return brother;        
    
    t->right = brother;
    return t;
}
