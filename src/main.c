#include <main.h>



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
    tree tmp_tree = malloc(sizeof (struct tree_t));

    tmp_tree->label = label;
    tmp_tree->nullary = nullary;
    tmp_tree->space = space;
    tmp_tree->tp = tp;
    tmp_tree->attr = attr;
    tmp_tree->daughters = daughters;
    tmp_tree->right = right;

    return tmp_tree;
}

    

attributes attributes_create (char *key, char *value) {
    attributes tmp_attributes = malloc(sizeof (struct attributes_t));

    tmp_attributes->key = key;
    tmp_attributes->value = value;

    return tmp_attributes;
}    



void attributes_add_tolist (attributes att, attributes att_list) {
    att->next = att_list;
}



void tree_add_brother (tree t, tree brother) {
    t->right = brother;
}



int main (void) {
    yyparse();
    return EXIT_SUCCESS;
}
