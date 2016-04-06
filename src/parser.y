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
#include <symbol.h>

#define PARSER_CONTEXT_GET_TREE(context) (context->t)

typedef struct parser_context_s {
    tree_t t;
    symbol_table_t st;
} *parser_context_t;
}

%code {
void yyerror (parser_context_t, char const *);
}

%parse-param {parser_context_t context}

%token LABEL
%token LABEL_XML
%token SPACES
%token CHARACTER
%token LET
%token IN
%token WHERE

%union {
    char c;
    char *s;
    word_t w;
    tree_t t;
    attributes_t a;
}

%type <c> CHARACTER
%type <s> LABEL LABEL_XML symbol
%type <w> characters
%type <t> root set-let set block label body content words word
%type <a> attributes attribute-list attribute

%right WHERE

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

block : '{' { symbol_table_increase_level(context->st); } body '}' { $$ = $3; symbol_table_decrease_level(context->st); }
      ;

let : LET symbol '=' set ';' { symbol_table_add(context->st, symbol_create($2, VARIABLE, $4)); }
    | LET symbol '=' set IN { symbol_table_increase_level(context->st); symbol_table_add(context->st, symbol_create($2, VARIABLE, $4)); } set { symbol_table_decrease_level(context->st); }
    | set { symbol_table_decrease_level(context->st); } WHERE symbol '=' set { symbol_table_increase_level(context->st); symbol_table_add(context->st, symbol_create($4, VARIABLE, $6)); }
    ;

symbol : LABEL     { $$ = $1; }
       | LABEL_XML { $$ = $1; }
       ;

label : LABEL attributes spaces block { $$ = tree_create($1, false, false, TREE, $2, $4, NULL);    }
      | LABEL block                   { $$ = tree_create($1, false, false, TREE, NULL, $2, NULL);  }
      | LABEL attributes '/'          { $$ = tree_create($1, true, false, TREE, $2, NULL, NULL);   }
      | LABEL '/'                     { $$ = tree_create($1, true, false, TREE, NULL, NULL, NULL); }
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

words : words word { $$ = tree_add_brother($1, $2); }
      | SPACES     { $$ = NULL; }
      | %empty     { $$ = NULL; }
      ;

word : characters SPACES { $$ = tree_create(word_to_string($1), true, true, WORD, NULL, NULL, NULL);  word_destroy($1); }
     | characters        { $$ = tree_create(word_to_string($1), true, false, WORD, NULL, NULL, NULL); word_destroy($1); }
     ;

characters : characters CHARACTER { $$ = word_cat($1, $2); }
           | CHARACTER { $$ = word_cat(word_create(), $1); }
           ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (parser_context_t context, char const *s) {
    if (!(context->t == NULL)) {
        tree_destroy(context->t);
    }
    symbol_table_destroy(context->st);
    fprintf(stderr, "%s\n", s);
}
