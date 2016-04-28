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
%token ARROW
%token IF
%token THEN
%token ELSE
%token INFEQ INF SUPEQ SUP EGAL OU ET
%token TMATCH WITH END

%union {
    char c;
    char *s;
    word_t w;
    struct attributes *a;
    struct ast *ast;
    struct patterns *patterns;
    struct pattern *pattern;
}

%type <c> CHARACTER
%type <s> LABEL LABEL_XML symbol
%type <w> word
%type <a> attributes attribute-list attribute
%type <ast> root let-global let set block label body value word-list empt-list
%type <ast> lambda-function affect expression application match
%type <patterns> patterns
%type <pattern> pattern
%type <pattern> pforest

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


body : set body              { $$ = mk_forest(false, $1, $2); }
     | value spaces body     { $$ = mk_forest(false, $1, $3); }
     | application ',' body  { $$ = mk_forest(false, $1, $3); }
     | application           { $$ = mk_forest(false, $1, NULL); }
     | %empty                { $$ = NULL; }
     ;


let-global : LET symbol spaces affect ';' let-global { $$ = mk_app(mk_fun($2, $6), $4); }
           | %empty                           { $$ = *root; }
           ;


let : LET symbol spaces affect IN expression                   { $$ = mk_app(mk_fun($2, $6), $4); }
    | '(' expression WHERE symbol spaces affect ')'            { $$ = mk_app(mk_fun($4, $2), $6); }
    | LET RECURSIVE symbol spaces affect IN expression         { $$ = mk_app(mk_fun($3, $7), mk_declrec($3, $5)); }
    | '(' expression WHERE RECURSIVE symbol spaces affect ')'  { $$ = mk_app(mk_fun($5, $2), mk_declrec($5, $7)); }
    ;


affect : symbol spaces affect    { $$ = mk_fun($1, $3); }
       | '=' expression          { $$ = $2; }
       | ARROW expression        { $$ = $2; }
       ;


lambda-function : FUNCTION affect { $$ = $2; }
                ;


application : application SPACES expression { $$ = mk_app($1, $3); }
            | symbol                 { $$ = mk_var($1); }
            ;


expression : '(' expression ')'       { $$ = $2; }
           | let                      { $$ = $1; }
           | lambda-function          { $$ = $1; }
           | set                      { $$ = $1; }
           | value                    { $$ = $1; }
           | '(' application ')'      { $$ = $2; }
           | match
           ;


symbol : LABEL     { $$ = $1; }
       | LABEL_XML { $$ = $1; }
       ;


label : LABEL attributes spaces block { $$ = mk_tree($1, false, false, false, $2, $4);    }
      | LABEL block                   { $$ = mk_tree($1, false, false, false, NULL, $2);  }
      | LABEL attributes '/'          { $$ = mk_tree($1, false, true, false, $2, NULL);   }
      | LABEL '/'                     { $$ = mk_tree($1, false, true, false, NULL, NULL); }
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


word-list : word SPACES word-list { $$ = mk_forest(false, mk_word(word_to_string($1)), $3); word_destroy($1); }
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


match   : TMATCH expression WITH patterns END    {$$ = mk_match($2, $4);}
        ;

patterns    :   '|' pforest ARROW expression patterns   {$$ = mk_patterns($2, $4, $5);}
            |   '|' pforest ARROW expression            {$$ = mk_patterns($2, $4, NULL);}
            ;

pforest     :   pattern pforest         {$$ = mk_pforest($1, $2);}
            |   pattern                 {$$ = $1;}
            ;

pattern     :   '_'                     {$$ = mk_wildcard(ANY);}
            |   LABEL '{' pattern '}'   {$$ = mk_ptree($1, false, $3);}
            |   LABEL '{' '}'           {$$ = mk_ptree($1, true, NULL);}
            |   '_' '{' pattern '}'     {$$ = mk_anytree(false, $3);}
            |   '_' '{' '}'             {$$ = mk_anytree(true, NULL);}
            |   '*' '_' '*'             {$$ = mk_wildcard(ANYSTRING);}
            |   '/' '_' '/'             {$$ = mk_wildcard(ANYFOREST);}
            |   '-' '_' '-'             {$$ = mk_wildcard(ANYSEQ);}
            |   symbol                  {$$ = mk_pattern_var($1, TREEVAR);}
            |   '*' symbol '*'          {$$ = mk_pattern_var($2, STRINGVAR);}
            |   '/' symbol '/'          {$$ = mk_pattern_var($2, FORESTVAR);}
            |   '-' symbol '-'          {$$ = mk_pattern_var($2, ANYVAR);}
            ;
%%

void yyerror (struct ast **root, char const *s) {
    free(*root);
    fprintf(stderr, "%s\n", s);
}
