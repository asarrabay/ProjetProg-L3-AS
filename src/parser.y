/**
 * \file parser.y
 * \brief Fichier contenant les regles constituant l'analyseur syntaxique du projet.
 * \author LABBE Emeric <br>
 * LAHAYE Valentin <br>
 * PARPAITE Thibault <br>
 * SARRABAYROUSE Alexis
 * \date 26 Fevrier 2016
 */

%{
#include <stdio.h>
#include <main.h>
#include <lexer.h>
  /*
   * Pourquoi on inclu pas tree.h ici?
   */
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
void yyerror (char const *);
%}

%token LABEL
%token LABEL_XML
%token SPACES
%token WORD
%token CHARACTER
                    
%union {
    char c;
    char *str;
    tree_t t;
    attributes_t att;
}

%type <str> LABEL
%type <t> WORD words content root set label body
%type <att> attribute attribute_list attributes

%start root

%%

root : root set     { $$ = tree_add_brother($1, $2); }
     | %empty     { $$ = NULL; }
     ;

set : '{' body '}'     { $$ = $2; }
    | label     { $$ = $1; }
    ;

label : LABEL attributes spaces '{' body '}'   { $$ = tree_create($1, false, false, tree, $2, $5, NULL);
                                                    printf("68 : %s\n", tree_to_xml($$)); }
        |       LABEL '{' body '}'             { $$ = tree_create($1, false, false, tree, NULL, $3, NULL); }
        |       LABEL attributes '/'           { $$ = tree_create($1, false, false, tree, $2, NULL, NULL); 
                                                    printf("%s\n", tree_to_xml($$));}
        |       LABEL '/'                      { $$ = tree_create($1, true, false, tree, NULL, NULL, NULL); }
      ;

attributes : '[' attribute_list ']'     { $$ = $2; }
           ;

attribute_list : attribute SPACES attribute_list     { $$ = attributes_add_tolist($3, $1); }
               | attribute     { $$ = $1; }
               | %empty        { $$ = NULL; }
               ;

attribute : LABEL spaces '=' content     { $$ = attributes_create($1, $4); }
          ;

body : set body               { $$ = tree_add_brother($1, $2); }
     | content spaces body     { $$ = tree_add_brother($1, $3); }
     | %empty                 { $$ = NULL; }
     ;

content : '"' words '"'     { $$ = $2; }
       ;

words : words WORD     { $$ = tree_add_brother($1, $2);}
           | %empty    { $$ = NULL; }
           ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (char const *s) {
    fprintf(stderr, "%s\n", s);
}
