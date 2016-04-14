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
#include <ast.h>
#include <word.h>
}

%code {
void yyerror (struct ast **, char const *);
}

%parse-param {struct ast **root}

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
    struct attributes *a;
    struct ast *ast;
}

%type <c> CHARACTER
%type <s> LABEL LABEL_XML symbol
%type <w> word
%type <a> attributes attribute-list attribute
%type <ast> root set-let set block label body value word-list empt-list

%start start

%%

start : root   { *root = $1; }
      | %empty { *root = NULL; }
      ;

root : root set-let { $$ = mk_forest(true, $1, $2); }
     | set-let      { $$ = $1; }
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
        ;

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


label : LABEL attributes spaces block { $$ = mk_tree($1, true, false, false, $2, $4);    }
      | LABEL block                   { $$ = mk_tree($1, true, false, false, NULL, $2);  }
      | LABEL attributes '/'          { $$ = mk_tree($1, true, true, false, $2, NULL);   }
      | LABEL '/'                     { $$ = mk_tree($1, true, true, false, NULL, NULL); }
      ;


attributes : '[' attribute-list ']' { $$ = $2; }
           | '[' empt-list ']'      { $$ = (struct attributes *)$2; }
           ;


attribute-list : attribute SPACES attribute-list { $$ = $1; $1->next = $3; }
               | attribute                       { $$ = $1; }
               ;


attribute : LABEL spaces '=' value { $$ = mk_attributes(mk_word($1), $4, NULL); }
          ;


value : '"' word-list '"' { $$ = $2; }
      | '"' empt-list '"' { $$ = $2; }
      ;


word-list : word SPACES word-list { $$ = mk_forest(true, mk_word(word_to_string($1)), $3); word_destroy($1); }
          | word SPACES           { $$ = mk_word(word_to_string($1)); word_destroy($1); }
          | word                  { $$ = mk_word(word_to_string($1)); word_destroy($1); }
          ;


word : word CHARACTER { $$ = word_cat($1, $2); }
     | CHARACTER      { $$ = word_cat(word_create(), $1); }
     ;


empt-list : SPACES { $$ = NULL; }
          | %empty { $$ = NULL; }
          ;


body : set-let body      { $$ = mk_forest(true, $1, $2); }
     | value spaces body { $$ = mk_forest(true, $1, $3); }
     | %empty            { $$ = NULL; }
     ;


spaces : SPACES
       | %empty
       ;

%%

void yyerror (struct ast **root, char const *s) {
    free(*root);
    fprintf(stderr, "%s\n", s);
}
