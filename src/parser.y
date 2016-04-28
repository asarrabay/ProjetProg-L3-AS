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
#include <path.h>
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
%token ARROW
%token IF
%token THEN
%token ELSE
%token INFEQ
%token INF
%token SUPEQ
%token SUP
%token EGAL
%token OU
%token ET
%token DIRECTORY
%token DOCUMENT

%union {
    char c;
    char *s;
    word_t w;
    int n;
    struct path *p;
    struct attributes *a;
    struct ast *ast;
}

%type <c> CHARACTER
%type <s> LABEL LABEL_XML symbol DIRECTORY DOCUMENT
%type <w> word
%type <n> top-directories
%type <p> path
%type <a> attributes attribute-list attribute
%type <ast> root let-global let set block label body value word-list empt-list
%type <ast> lambda-function affect expression application import

%left WHERE

%start start

%%

start : root   { *root = $1; }
      ;


root : root set   { $$ = mk_forest(true, $1, $2); }
     | let-global { $$ = $1; }
     ;


set : block      { $$ = $1; }
    | label      { $$ = $1; }
    ;


block : '{' body '}' { $$ = $2; }
      ;


body : set body              { $$ = mk_forest(true, $1, $2);            }
     | value spaces body     { $$ = mk_forest(true, $1, $3);            }
     | application ',' body  { $$ = mk_forest(false, $1, $3);           }
     | application           { $$ = mk_forest(false, $1, NULL);         }
     | symbol ',' body       { $$ = mk_forest(false, mk_var($1), $3);   }
     | symbol                { $$ = mk_forest(false, mk_var($1), NULL); }
     | %empty                { $$ = NULL; }
     ;


let-global : LET symbol affect ';' let-global { $$ = mk_app(mk_fun($2, $5), $3); }
           | %empty                           { $$ = *root; }
           ;


let : LET symbol affect IN expression           { $$ = mk_app(mk_fun($2, $5), $3); }
    | '(' expression WHERE symbol affect ')'            { $$ = mk_app(mk_fun($4, $2), $5); }
    | LET RECURSIVE symbol affect IN expression { $$ = mk_app(mk_fun($3, $6), mk_declrec($3, $4)); }
    | '(' expression WHERE RECURSIVE symbol affect ')'  { $$ = mk_app(mk_fun($5, $2), mk_declrec($5, $6)); }
    ;


affect : symbol affect    { $$ = mk_fun($1, $2); }
       | '=' expression   { $$ = $2; }
       | ARROW expression { $$ = $2; }
       ;


lambda-function : FUNCTION affect { $$ = $2; }
                ;

     
application : application expression { $$ = mk_app($1, $2); }
            | symbol                 { $$ = mk_var($1); }
            ;


expression : '(' expression ')' { $$ = $2; }
           | let                { $$ = $1; }
           | lambda-function    { $$ = $1; }
           | set                { $$ = $1; }
           | value              { $$ = $1; }
           | application        { $$ = $1; }
           | import             { $$ = $1; }
           ;


import : '$' path DOCUMENT ARROW symbol { PATH_SET_FILENAME($2, $3); PATH_SET_DECLNAME($2, $5); $$ = mk_import($2); }
       ;


path : top-directories DIRECTORY { $$ = path_new($1, $2, NULL, NULL);   }
     | top-directories           { $$ = path_new($1, NULL, NULL, NULL); }
     | DIRECTORY                 { $$ = path_new(0, $1, NULL, NULL);    }
     | %empty                    { $$ = path_new(0, NULL, NULL, NULL);  }
     ;


top-directories : top-directories '.' { $$ = ++$1; }
                | '.'                 { $$ = 1; }
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
