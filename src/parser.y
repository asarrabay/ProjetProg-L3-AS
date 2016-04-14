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
%token CHARACTER
%token LET
%token IN
%token WHERE
%token OP
%token REC
%token IF
%token THEN
%token ELSE
%token ASSOC
%token FUNC

%union {
    char c;
    char *s;
    word_t w;
    tree_t t;
    attributes_t a;
}

%type <c> CHARACTER
%type <s> LABEL LABEL_XML symbol
%type <w> word
%type <t> root set-let set block label body value word-list empt-list
%type <a> attributes attribute-list attribute

%start root

%%

root : root set-let { context->t = tree_add_brother(context->t, $2); }
     | %empty       { $$ = NULL; }
     ;


set-let : set { $$ = $1; }
        | let-var { $$ = NULL; }
        | let-fun { $$ = NULL; }
        ;


set : block { $$ = $1; }
    | label { $$ = $1; }
    ;


block : '{' body '}' { $$ = $2; }
      ;



let-global : LET symbol '=' exp ';' let-global { $$ = mk_app(mk_fun($2, $6), $4); }
           | %empty                            { $$ = *root; }
	   ;


let-var : LET symbol '=' exp IN exp { $$ = mk_app(mk_fun($2, $6), $4); }
        | exp WHERE symbol '=' exp  { $$ = mk_app(mk_fun($3, $1), $5); }
        ;


/* A modifier */
let-fun : LET symbol symbol-list '=' FUNC symbol-list ASSOC exp ';'
        | LET symbol symbol-list '=' FUNC symbol-list ASSOC exp ';'
        | LET REC symbol-list '=' FUNC symbol-list ASSOC exp ';'


exp : '(' exp ')'
    | IF exp THEN exp ELSE exp
    | exp OP exp
    | set
    ;


symbol-list : symbol symbol-list
            | symbol
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
           | '[' empt-list ']'      { $$ = (attributes_t)$2; }
           ;


attribute-list : attribute SPACES attribute-list { $$ = attributes_add_ahead($1, $3); }
               | attribute                       { $$ = $1; }
               ;


attribute : LABEL spaces '=' value { $$ = attributes_create($1, $4); }
          ;


value : '"' word-list '"' { $$ = $2; }
      | '"' empt-list '"' { $$ = $2; }
      ;


word-list : word SPACES word-list { tree_t t = tree_create(word_to_string($1), true, true, WORD, NULL, NULL, NULL);
                                    word_destroy($1);
                                    $$ = tree_add_brother(t, $3); }
          | word SPACES           { $$ = tree_create(word_to_string($1), true, true, WORD, NULL, NULL, NULL); word_destroy($1); }
          | word                  { $$ = tree_create(word_to_string($1), true, false, WORD, NULL, NULL, NULL); word_destroy($1); }
          ;


word : word CHARACTER { $$ = word_cat($1, $2); }
     | CHARACTER      { $$ = word_cat(word_create(), $1); }
     ;


empt-list : SPACES { $$ = NULL; }
          | %empty { $$ = NULL; }
          ;


body : set-let body      { $$ = tree_add_brother($1, $2); }
     | value spaces body { $$ = tree_add_brother($1, $3); }
     | %empty            { $$ = NULL; }
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
