#include <stdlib.h>
#include <tree.h>
#include <stdio.h>
#include <string.h>

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
    
    tree_t t = malloc(sizeof (struct tree_s));

    t->label     = label;
    t->nullary   = nullary;
    t->space     = space;
    t->tp        = tp;
    t->attr      = attr;
    t->daughters = daughters;
    t->right     = right;

    return t;
}

    

attributes_t attributes_create (char *key, tree_t text) {
    attributes_t attr = malloc(sizeof (struct attributes_s));
    attr->key   = key;
    attr->value = text->label;
    attr->next  = NULL;

    return attr;
}    



attributes_t attributes_add_ahead (attributes_t attr_list, attributes_t attr) {
    attr->next = attr_list;
    return attr;
}



tree_t tree_add_brother (tree_t t, tree_t brother) {
    if (t == NULL)
        return brother;        
    
    t->right = tree_add_brother(t->right, brother);
    return t;
}

static char * attributs_to_string(attributes_t attr){
    char* str;
    int size_key = strlen(attr->key);
    int size_value = strlen(attr->value);
    int size = size_key + size_value + 4; // +3 pour =, ", " et '\0'
    if(attr->next != NULL)
        size++;

    str = malloc(sizeof(char) * size);
    int index = 0;
    // str = key
    for(int i = 0; i < size_key; i++)
        str[index++] = attr->key[i];

    // str = key=
    str[index++] = '=';

    //str = key="value"
    str[index++] = '"';
    for (int i = 0; i < size_value; i++)
        str[index++]  = attr->value[i];
    str[index++] = '"';
    
    if(attr->next != NULL) {
        str[index] = ' ';
        char * str_right = attributs_to_string(attr->next);
        str = realloc(str, strlen(str) + strlen(str_right) + 1);
        strcat(str, str_right);
    }
    return str;

}

static char * tabulation(int tab_level){
    char *tab = malloc(sizeof(char) * tab_level + 1);
    for (int i = 0; i < tab_level; ++i)
        tab[i] = '\t';
    tab[tab_level] = '\0';
    return tab;
}

/**
 * Concatene str2 à str1 en faisant un realloc de str1 et retourne le nouveau pointeur de str1
 */
static char * str_concat(char *str1, char *str2){
    str1 = realloc(str1, sizeof(char) * (strlen(str1) + strlen(str2) + 1));
    strcat(str1, str2);
    return str1;
}

char* tree_to_xml(tree_t t, int tab_level){
    if(t == NULL){
        char *ret = malloc(sizeof(char));
        *ret = '\0';
        return ret;
    }
    char *xml;
    int size_label = strlen(t->label);
    if (t->tp == word) {
        if(t->space)
            size_label++;
        xml = malloc(sizeof(char) * size_label + 1);
        strcpy(xml, t->label);
        if(t->space)
            strcat(xml, " ");
        

    } else {    
        if(t->attr != NULL){
            // xml += <label attr
            xml = malloc(sizeof(char) * (size_label + 3 + tab_level));   // +3 pour : '<', ' ', '\0'
            if(tab_level != 0){
                strcpy(xml, tabulation(tab_level));
                strcat(xml, "<");
            } else
                strcpy(xml, "<");
            strcat(xml, t->label);
            strcat(xml, " ");
            char *attrs = attributs_to_string(t->attr);
            xml = str_concat(xml, attrs);
            free(attrs);
        } else {
            xml = malloc(sizeof(char) * (size_label + 2 + tab_level));   // +2 pour : '<', '\0'
            if(tab_level != 0){
                strcpy(xml, tabulation(tab_level));
                strcat(xml, "<");
            } else
                strcpy(xml, "<");
            strcat(xml, t->label);
        }
        if (t->nullary == true) {
            // xml += /> xml_son
            char *xml_son = tree_to_xml(t->daughters, tab_level);
            xml = str_concat(xml, "/>\n");
            if(tab_level != 0)
                xml = str_concat(xml, tabulation(tab_level));
            xml = str_concat(xml, xml_son);
            free(xml_son);
        } else {
            // xml += > xml_son </label>
            xml = str_concat(xml, ">\n");
            char *xml_son = tree_to_xml(t->daughters, tab_level++);
            if(tab_level != 0)
                xml = str_concat(xml, tabulation(tab_level));
            xml = str_concat(xml, xml_son);
            free(xml_son);
            int size = strlen(xml);
            char *tmp;
            tab_level--;
            if (xml[size - 1] == '\n') {
                tmp = malloc(sizeof(char) * (size_label + 4 + tab_level)); // +4 pour : '<', '/', '>', '\0' 
                if(tab_level != 0){
                    tmp = strcpy(tmp, tabulation(tab_level));   
                    strcat(tmp, "</");
                } else
                    strcpy(tmp, "</");

            } else {
                tmp = malloc(sizeof(char) * (size_label + 4 + tab_level)); // +5 pour : '\n', '<', '/', '>', '\0'  
                strcpy(tmp, "\n");
                if(tab_level != 0)
                    tmp = strcat(tmp, tabulation(tab_level)); 
                strcat(tmp, "</");
            }
            strcat(tmp, t->label);
            strcat(tmp, ">");
            xml = str_concat(xml, tmp);
            free(tmp);
        }
        
    }

    // xml += xml_right
    char *xml_right = tree_to_xml(t->right, tab_level);
    xml = str_concat(xml, xml_right);
    //xml = str_concat(xml, "\n");
    return xml;
}
