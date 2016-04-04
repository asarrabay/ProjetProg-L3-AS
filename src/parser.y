/**
 * \file parser.y
 * \brief Fichier contenant les regles constituant l'analyseur syntaxique du projet.
 * \author LABBE Emeric <br>
 * LAHAYE Valentin <br>
 * PARPAITE Thibault <br>
 * SARRABAYROUSE Alexis
 * \date 26 Fevrier 2016
 */

%code top {
#include <stdio.h>
#include <lexer.h>
}

%code requires {
#include <word.h>
#include <tree.h>
}

%code {
void yyerror (tree_t *, char const *);
}

%parse-param {tree_t *root}

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

%type <c> CHARACTER
%type <s> LABEL
%type <w> characters
%type <t> root set label body content words word
%type <a> attributes attribute_list attribute

%start root

%%

root : root set { *root = tree_add_brother(*root, $2); }
     | %empty { $$ = NULL; }
     ;

set : '{' body '}' { $$ = $2; }
    | label        { $$ = $1; }
    ;

label : LABEL attributes spaces '{' body '}' { $$ = tree_create($1, false, false, TREE, $2, $5, NULL);    }
      | LABEL '{' body '}'                   { $$ = tree_create($1, false, false, TREE, NULL, $3, NULL);  }
      | LABEL attributes '/'                 { $$ = tree_create($1, true, false, TREE, $2, NULL, NULL);   }
      | LABEL '/'                            { $$ = tree_create($1, true, false, TREE, NULL, NULL, NULL); }
      ;

attributes : '[' attribute_list ']' { $$ = $2; }
           ;

attribute_list : attribute SPACES attribute_list { $$ = attributes_add_ahead($1, $3); }
               | attribute                       { $$ = $1; }
               | %empty                          { $$ = NULL; }
               ;

attribute : LABEL spaces '=' content { $$ = attributes_create($1, $4); }
          ;

body : set body            { $$ = tree_add_brother($1, $2); }
     | content spaces body { $$ = tree_add_brother($1, $3); }
     | %empty              { $$ = NULL; }
     ;

content : '"' words '"' { $$ = $2; }
        ;

words : words word { $$ = tree_add_brother($1, $2); }
      | SPACES     { $$ = NULL; }
      | %empty     { $$ = NULL; }
      ;

word : characters SPACES { $$ = tree_create(word_to_string($1), true, true, WORD, NULL, NULL, NULL);
                           word_destroy($1);
                         }
     | characters        { $$ = tree_create(word_to_string($1), true, false, WORD, NULL, NULL, NULL);
                           word_destroy($1);
                         }
     ;

characters : characters CHARACTER { $$ = word_cat($1, $2); }
           | CHARACTER { $$ = word_cat(word_create(), $1); }
           ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (tree_t *t, char const *s) {
    if (!(t == NULL) && !(*t == NULL)) { 
	tree_destroy(*t);
	*t = NULL;
    }
    fprintf(stderr, "%s\n", s);
}
