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
#include <word.h>
#include <tree.h>
  
void yyerror (char const *);
%}

%token LABEL
%token LABEL_XML
%token SPACES
%token CHARACTER
                    
%union {
    char c;
    char *s;
    word_t w;
    tree_t t;
    attributes_t a;
}

%type <s> LABEL
%type <t> word words content root set label body
%type <a> attribute attribute_list attributes
%type <w> characters

%start root

%%

root : root set     { G_main_root = tree_add_brother(G_main_root, $2); }
     | %empty       { $$ = NULL; }
     ;

set : '{' body '}'     { $$ = $2; }
    | label            { $$ = $1; }
    ;

label : LABEL attributes spaces '{' body '}'   { $$ = tree_create($1, false, false, tree, $2, $5, NULL); }
        |       LABEL '{' body '}'             { $$ = tree_create($1, false, false, tree, NULL, $3, NULL); }
        |       LABEL attributes '/'           { $$ = tree_create($1, true, false, tree, $2, NULL, NULL); }
        |       LABEL '/'                      { $$ = tree_create($1, true, false, tree, NULL, NULL, NULL); }
      ;

attributes : '[' attribute_list ']'     { $$ = $2; }
           ;

attribute_list : attribute SPACES attribute_list     { $$ = attributes_add_ahead($3, $1); }
               | attribute                           { $$ = $1; }
               | %empty                              { $$ = NULL; }
               ;

attribute : LABEL spaces '=' content     { $$ = attributes_create($1, $4); }
          ;

body : set body               { $$ = tree_add_brother($1, $2); }
     | content spaces body    { $$ = tree_add_brother($1, $3); }
     | %empty                 { $$ = NULL; }
     ;

content : '"' words '"'     { $$ = $2; }
        ;

words : words word     { $$ = tree_add_brother($1, $2);}
      | %empty         { $$ = NULL; }
      ;

word : characters SPACES     { $$ = tree_create(word_to_string($1), true, true, word, NULL, NULL, NULL);
                               word_destroy($1); }
     | characters            { $$ = tree_create(word_to_string($1), true, false, word, NULL, NULL, NULL);
                               word_destroy($1); }
     ;

characters : characters CHARACTER     { $$ = word_cat($1, $2); }
           | %empty                   { $$ = word_create(); }
           ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (char const *s) {
    fprintf(stderr, "%s\n", s);
}
