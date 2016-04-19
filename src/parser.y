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
%token RECURSIVE
%token FUNCTION
%token ASSOC
%token IF
%token THEN
%token ELSE
%token OPERATOR

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
%type <ast> root let-global let-var let-fun set block label body value word-list empt-list
%type <ast> expression application lambda-function parametres arguments def-function

%start start

%%

start : root   { *root = $1; }
      | %empty { *root = NULL; }
      ;


root : root set   { $$ = mk_forest(true, $1, $2); }
     | let-global { $$ = $1; }
     ;


set : block      { $$ = $1; }
    | label      { $$ = $1; }
    | let-var    { $$ = $1; }
    | let-fun    { $$ = $1; }
    ;


block : '{' body '}' { $$ = $2; }
      ;


body : set body          { $$ = mk_forest(true, $1, $2); }
     | value spaces body { $$ = mk_forest(true, $1, $3); }
     | application body  { $$ = mk_forest(false, $1, $2); }
     | symbol ',' body   { $$ = mk_forest(false, mk_var($1), $3); }
     | symbol            { $$ = mk_forest(false, mk_var($1), NULL); }
     | %empty            { $$ = NULL; }
     ;


let-global : LET symbol '=' expression ';' let-global { $$ = mk_app(mk_fun($2, $6), $4); }
           | %empty                                   { $$ = *root; }
	   ;


let-var : LET symbol '=' expression IN expression           { $$ = mk_app(mk_fun($2, $6), $4); }
        | expression WHERE symbol '=' expression            { $$ = mk_app(mk_fun($3, $1), $5); }
        | LET RECURSIVE symbol '=' expression IN expression { $$ = mk_app(mk_fun($3, $7), mk_declrec($3, $5)); }
        | expression WHERE RECURSIVE symbol '=' expression  { $$ = mk_app(mk_fun($4, $1), mk_declrec($4, $6)); }
        ;


/* Les fonctions à revoir */
let-fun : LET def-function ';'           { $$ = $2; }             
        | LET RECURSIVE def-function ';' { $$ = $3; }
        ;


lambda-function : FUNCTION parametres ASSOC expression     { $$ = mk_app(mk_fun(NULL, $4), $2); }
                ;


def-function : lambda-function                          { $$ = $1; }
             | symbol parametres '=' expression         { $$ = mk_app(mk_fun($1, $4), $2); }
             ;  

     
application : lambda-function arguments { $$ = mk_app($1, $2); }
            | symbol arguments          { $$ = mk_app(mk_var($1), $2); }
            ;


arguments : expression arguments { $$ = mk_forest(true, $1, $2); }
          | %empty               { $$ = NULL; }
          ;

   
parametres : symbol parametres     { $$ = mk_forest(true, mk_var($1), $2); }
           | symbol                { $$ = mk_var($1); }
           ;
/* End à revoir*/ 

expression : '(' expression ')'                            { $$ = $2; }
           | IF expression THEN expression ELSE expression { $$ = NULL; }
           | expression OPERATOR expression                { $$ = NULL; }
           | def-function                                  { $$ = $1; }
           | set                                           { $$ = $1; }
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


value : '"' spaces word-list '"' { $$ = $3; }
      | '"' empt-list '"'        { $$ = $2; }
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


spaces : SPACES
       | %empty
       ;

%%

void yyerror (struct ast **root, char const *s) {
    free(*root);
    fprintf(stderr, "%s\n", s);
}
