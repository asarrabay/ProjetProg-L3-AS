#include <stdlib.h>
#include <stdio.h>
#include <tree.h>

struct attributes_s {
    char *s_key;
    char *s_value;
    attributes_t next;
};

struct tree_s {
    char *s_label;
    bool nullary;
    bool space;
    enum tree_type_e type;
    attributes_t a;
    tree_t daughters;
    tree_t right;
};

tree_t tree_create (char *s_label, bool nullary, bool space, enum tree_type_e type, attributes_t a, tree_t daughters, tree_t right) {
    tree_t t = malloc(sizeof (struct tree_s));
    t->s_label   = s_label;
    t->nullary   = nullary;
    t->space     = space;
    t->type      = type;
    t->a         = a;
    t->daughters = daughters;
    t->right     = right;
    return t;
}

void tree_destroy (tree_t t) {
    if (!(t->daughters == NULL)) {
	tree_destroy(t->daughters);
    }
    if (!(t->right == NULL)) {
	tree_destroy(t->right);
    }
    if (!(t->a == NULL)) {
	attributes_destroy(t->a);
    }
    free(t->s_label);
    free(t);
}

tree_t tree_add_brother (tree_t t, tree_t brother) {
    if (t == NULL) {
        return brother;
    }
    t->right = tree_add_brother(t->right, brother);
    return t;
}

void tree_to_xml (tree_t t, FILE *fdout) {
    switch (t->type) {
    case tree :
	fprintf(fdout, "<%s", t->s_label);
	if (!(t->a == NULL)) {
	    attributes_to_xml(t->a, fdout);
	}
	if (t->nullary) {
	    fprintf(fdout, "/>");
	    break ;
	}
	fprintf(fdout, ">");
	if (!(t->daughters == NULL)) {
	    tree_to_xml(t->daughters, fdout);
	}
	fprintf(fdout, "</%s>", t->s_label);
	break ;

    case word :
	fprintf(fdout, "%s", t->s_label);
	if (t->space) {
	    fprintf(fdout, " ");
	}
	break ;

    default : break ;
    }
    if (!(t->right == NULL)) {
	tree_to_xml(t->right, fdout);
    }
}

attributes_t attributes_create (char *s_key, tree_t text) {
    attributes_t a = malloc(sizeof (struct attributes_s));
    a->s_key   = s_key;
    a->s_value = text->s_label;
    a->next  = NULL;
    return a;
}

void attributes_destroy (attributes_t a) {
    if (!(a->next == NULL)) {
	attributes_destroy(a->next);
    }
    free(a->s_key);
    free(a->s_value);
    free(a);
}

attributes_t attributes_add_ahead (attributes_t a, attributes_t next) {
    a->next = next;
    return a;
}

void attributes_to_xml (attributes_t a, FILE *fdout) {
    fprintf(fdout, " %s=\"%s\"", a->s_key, a->s_value);
    if (!(a->next == NULL)) {
	attributes_to_xml(a->next, fdout);
    }
}
