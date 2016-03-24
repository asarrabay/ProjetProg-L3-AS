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
#include <tree.h>
  
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

root : root set     { $$ = tree_add_brother($1, $2); printf("LA");}
     | %empty     { $$ = NULL; }
     ;

set : '{' body '}'     { $$ = $2; }
    | label     { $$ = $1; }
    ;

label : LABEL attributes spaces '{' body '}'   { $$ = tree_create($1, false, false, tree, $2, $5, NULL); }
        |       LABEL '{' body '}'             { $$ = tree_create($1, false, false, tree, NULL, $3, NULL); }
        |       LABEL attributes '/'           { $$ = tree_create($1, true, false, tree, $2, NULL, NULL); }
        |       LABEL '/'                      { $$ = tree_create($1, true, false, tree, NULL, NULL, NULL); }
      ;

attributes : '[' attribute_list ']'     { $$ = $2; }
           ;

attribute_list : attribute SPACES attribute_list     { $$ = attributes_add_ahead($3, $1); }
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
