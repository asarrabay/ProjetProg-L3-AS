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
#include <tree.h>
#include <symbol.h>

#define PARSER_CONTEXT_GET_TREE(context) (context->t)

typedef struct parser_context_s {
    tree_t t;
    symbol_environment_t se;
} *parser_context_t;
}

%code {
void yyerror (parser_context_t, char const *);
}

%parse-param {parser_context_t context}

%token LABEL
%token LABEL_XML
%token SPACES
%token WORD
%token LET
%token IN
%token WHERE

%union {
    char *s;
    tree_t t;
    attributes_t a;
}

%type <s> LABEL LABEL_XML symbol
%type <t> root set-let set block label body content words WORD 
%type <a> attributes attribute-list attribute

%start root

%%

root : root set-let { context->t = tree_add_brother(context->t, $2); }
     | %empty       { $$ = NULL; }
     ;

set-let : set { $$ = $1; }
        | let { $$ = NULL; }
        ;

set : block { $$ = $1; }
    | label { $$ = $1; }
    ;

block : '{' { symbol_environment_increase_level(context->se); } body '}' { $$ = $3; symbol_environment_decrease_level(context->se); }
      ;

let : LET symbol '=' set ';' { symbol_environment_add(context->se, symbol_create($2, VARIABLE, $4)); }
    | LET symbol '=' set IN { symbol_environment_increase_level(context->se); symbol_environment_add(context->se, symbol_create($2, VARIABLE, $4)); } set { symbol_environment_decrease_level(context->se); }
    | set { symbol_environment_decrease_level(context->se); } WHERE symbol '=' set { symbol_environment_increase_level(context->se); symbol_environment_add(context->se, symbol_create($4, VARIABLE, $6)); }
    ;

symbol : LABEL     { $$ = $1; }
       | LABEL_XML { $$ = $1; }
       ;

label : LABEL attributes spaces block { $$ = tree_create($1, false, false, tree, $2, $4, NULL);    }
      | LABEL block                   { $$ = tree_create($1, false, false, tree, NULL, $2, NULL);  }
      | LABEL attributes '/'          { $$ = tree_create($1, true, false, tree, $2, NULL, NULL);   }
      | LABEL '/'                     { $$ = tree_create($1, true, false, tree, NULL, NULL, NULL); }
      ;

attributes : '[' attribute-list ']' { $$ = $2; }
           ;

attribute-list : attribute SPACES attribute-list { $$ = attributes_add_ahead($1, $3); }
               | attribute                       { $$ = $1; }
               | %empty                          { $$ = NULL; }
               ;

attribute : LABEL spaces '=' content { $$ = attributes_create($1, $4); }
          ;

body : set-let body        { $$ = tree_add_brother($1, $2); }
     | content spaces body { $$ = tree_add_brother($1, $3); }
     | %empty              { $$ = NULL; }
     ;

content : '"' words '"' { $$ = $2; }
        ;

words : words WORD { $$ = tree_add_brother($1, $2); }
      | %empty     { $$ = NULL; }
      ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (parser_context_t context, char const *s) {
    if (!(context->t == NULL)) {
        tree_destroy(context->t);
    }
    
    symbol_environment_destroy(context->se);
    fprintf(stderr, "%s\n", s);
}
