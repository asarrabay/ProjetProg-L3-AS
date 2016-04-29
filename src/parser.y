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
#include <path.h>
}

%code {
void yyerror (struct ast **, char const *);
}

%parse-param {struct ast **root}

%token LABEL
%token LABEL_XML
%token SPACES
%token CHARACTER
%token NUMBER
%token LET
%token IN
%token WHERE
%token RECURSIVE
%token FUNCTION
%token DIRECTORY
%token DOCUMENT
%token ARROW
%token IF
%token THEN
%token ELSE
%token TMATCH WITH END
%token DIVIDE INFEQ INF SUPEQ SUP EGAL NEGAL OU ET


%union {
    int n;
    char c;
    char *s;
    word_t w;
    struct path *p;
    struct attributes *a;
    struct ast *ast;
    struct patterns *patterns;
    struct pattern *pattern;
}


%type <n> NUMBER top-directories
%type <c> CHARACTER
%type <s> LABEL LABEL_XML symbol DIRECTORY DOCUMENT
%type <w> word
%type <p> path
%type <a> attributes attribute-list attribute
%type <ast> root let-global let set block label body content word-list empt-list
%type <ast> expression expression-partielle expression-conditionnelle
%type <ast> expression-booleenne-e expression-booleenne-t expression-ari-e expression-ari-t expression-ari-f
%type <ast> lambda-function affect application match import
%type <patterns> patterns
%type <pattern> pattern pforest

%start start


%%


start : root   { printf("Line :%d\n", __LINE__); *root = $1; }
      ;


root : root set   { $$ = mk_forest(false, $1, $2); }
     | let-global { $$ = $1; }
     ;


let-global : LET symbol spaces affect ';' let-global                        { $$ = mk_app(mk_fun($2, $6), $4); }
           | %empty                                                         { $$ = *root; }
           ;


set : block      { $$ = $1; }
    | label      { $$ = $1; }
    ;


block : '{' body '}' { $$ = $2; }
      ;


body : set body              { $$ = mk_forest(false, $1, $2); }
     | content spaces body   { $$ = mk_forest(false, $1, $3); }
     | application ',' body  { $$ = mk_forest(false, $1, $3); }
     | application           { $$ = mk_forest(false, $1, NULL); }
     | %empty                { $$ = NULL; }
     ;


symbol : LABEL               { $$ = $1; }
       | LABEL_XML           { $$ = $1; }
       ;


expression : expression-booleenne-e              { $$ = $1; }
           | expression-conditionnelle           { $$ = $1; }
           | let                                 { $$ = $1; }
           | lambda-function                     { $$ = $1; }
           | match                               { $$ = $1; }
           | import                              { $$ = $1; }
           ;


expression-partielle : '(' expression ')'        { $$ = $2; }
                     | set                       { $$ = $1; }
                     | content                   { $$ = $1; }
                     ;


expression-conditionnelle : IF expression-booleenne-e THEN expression ELSE expression { $$ = mk_cond($2, $4, $6); }
                          ;


expression-booleenne-e : expression-booleenne-e OU expression-booleenne-t   { $$ = mk_app(mk_app(mk_binop(OR), $1), $3);  }
                       | expression-booleenne-e ET expression-booleenne-t   { $$ = mk_app(mk_app(mk_binop(AND), $1), $3); }
                       | expression-booleenne-t                             { $$ = $1; }
                       ;


expression-booleenne-t : expression-booleenne-t INFEQ expression-ari-e      { $$ = mk_app(mk_app(mk_binop(LEQ), $1), $3); }
                       | expression-booleenne-t INF expression-ari-e        { $$ = mk_app(mk_app(mk_binop(LE), $1), $3);  }
                       | expression-booleenne-t SUPEQ expression-ari-e      { $$ = mk_app(mk_app(mk_binop(GEQ), $1), $3); }
                       | expression-booleenne-t SUP expression-ari-e        { $$ = mk_app(mk_app(mk_binop(GE), $1), $3);  }
                       | expression-booleenne-t EGAL expression-ari-e       { $$ = mk_app(mk_app(mk_binop(EQ), $1), $3);  }
                       | expression-booleenne-t NEGAL expression-ari-e      { $$ = mk_app(mk_app(mk_binop(NEQ), $1), $3); }
                       | expression-ari-e                                   { $$ = $1; }
                       ;


expression-ari-e : expression-ari-e '+' expression-ari-t                    { $$ = mk_app(mk_app(mk_binop(PLUS), $1), $3);  }
                 | expression-ari-e '-' expression-ari-t                    { $$ = mk_app(mk_app(mk_binop(MINUS), $1), $3); }
                 | expression-ari-t                                         { $$ = $1; }
                 ;


expression-ari-t : expression-ari-t '*' expression-ari-f                    { $$ = mk_app(mk_app(mk_binop(MULT), $1), $3); }
                 | expression-ari-t DIVIDE expression-ari-f                 { $$ = mk_app(mk_app(mk_binop(DIV), $1), $3);  }
                 | expression-ari-f                                         { $$ = $1; }
                 ;


expression-ari-f : expression-partielle spaces                              { $$ = $1; }
                 | application spaces                                       { $$ = $1; }
                 | NUMBER                                                   { $$ = mk_integer($1); }
                 | '!' expression-partielle                                 { $$ = mk_app(mk_unaryop(NOT), $2); }
                 | '!' application                                          { $$ = mk_app(mk_unaryop(NOT), $2); }
                 | '!' NUMBER                                               { $$ = mk_app(mk_unaryop(NEG), mk_integer($2)); }
                 ;


let : LET symbol spaces affect IN expression                                { $$ = mk_app(mk_fun($2, $6), $4); }
    | '(' expression WHERE symbol spaces affect ')'                         { $$ = mk_app(mk_fun($4, $2), $6); }
    | LET RECURSIVE symbol spaces affect IN expression                      { $$ = mk_app(mk_fun($3, $7), mk_declrec($3, $5)); }
    | '(' expression WHERE RECURSIVE symbol spaces affect ')'               { $$ = mk_app(mk_fun($5, $2), mk_declrec($5, $7)); }
    ;


affect : symbol spaces affect                                               { $$ = mk_fun($1, $3); }
       | '=' expression                                                     { $$ = $2; }
       | ARROW expression                                                   { $$ = $2; }
       ;


lambda-function : FUNCTION affect                                           { $$ = $2; }
                ;


application : application SPACES expression-partielle                       { $$ = mk_app($1, $3); }
            | application SPACES symbol                                     { $$ = mk_app($1, mk_var($3) ); }
            | application SPACES NUMBER                                     { $$ = mk_app($1, mk_integer($3) ); }
            | symbol                                                        { $$ = mk_var($1); }
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


attribute : LABEL spaces '=' content { $$ = mk_attributes(false, mk_word($1), $4, NULL); }
          ;


content : '"' spaces word-list '"' { $$ = $3; }
        | '"' empt-list '"'        { $$ = $2; }
        ;


word-list : word SPACES word-list { $$ = mk_forest(false, mk_word(word_to_string($1)), $3); word_destroy($1); }
          | word SPACES           { $$ = mk_word(word_to_string($1)); word_destroy($1);                       }
          | word                  { $$ = mk_word(word_to_string($1)); word_destroy($1);                       }
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


match : TMATCH expression WITH patterns END        { $$ = mk_match($2, $4); }
      ;


patterns : '|' pforest ARROW expression patterns   { $$ = mk_patterns($2, $4, $5);   }
         | '|' pforest ARROW expression            { $$ = mk_patterns($2, $4, NULL); }
         | '|' '{' pforest '}' ARROW expression patterns   { $$ = mk_patterns($3, $6, $7);   }
         | '|' '{' pforest '}' ARROW expression            { $$ = mk_patterns($3, $6, NULL); }
         ;


pforest : pattern pforest                          { $$ = mk_pforest($1, $2); }
    //    | '{' pforest '}'                          {$$ = $2; }
        | %empty                                   { $$ = NULL; }
        ;


pattern : '_'                                      { $$ = mk_wildcard(ANY);              }
        | LABEL '{' pattern '}'                    { $$ = mk_ptree($1, false, $3);       }
        | LABEL '{' '}'                            { $$ = mk_ptree($1, true, NULL);      }
        | '_' '{' pattern '}'                      { $$ = mk_anytree(false, $3);         }
        | '_' '{' '}'                              { $$ = mk_anytree(true, NULL);        }
        | '*' '_' '*'                              { $$ = mk_wildcard(ANYSTRING);        }
        | '/' '_' '/'                              { $$ = mk_wildcard(ANYFOREST);        }
        | '-' '_' '-'                              { $$ = mk_wildcard(ANYSEQ);           }
        | symbol spaces                            { $$ = mk_pattern_var($1, TREEVAR);   }
        | '*' symbol '*'                           { $$ = mk_pattern_var($2, STRINGVAR); }
        | '/' symbol '/'                           { $$ = mk_pattern_var($2, FORESTVAR); }
        | '-' symbol '-'                           { $$ = mk_pattern_var($2, ANYVAR);    }
        ;


import : '$' path DOCUMENT ARROW symbol { PATH_SET_FILENAME($2, $3);
                                          PATH_SET_DECLNAME($2, $5);
					  $$ = mk_import($2);       }
       ;


path : top-directories DIRECTORY { $$ = path_new($1, $2, NULL, NULL);   }
     | top-directories           { $$ = path_new($1, NULL, NULL, NULL); }
     | DIRECTORY                 { $$ = path_new(0, $1, NULL, NULL);    }
     | %empty                    { $$ = path_new(0, NULL, NULL, NULL);  }
     ;


top-directories : top-directories '.' { $$ = ++$1; }
                | '.'                 { $$ = 1; }
                ;


%%

void yyerror (struct ast **root, char const *s) {
    printf("%p -> %p\n", (void *)root,(void *) *root );
    printf("%d: %s at %s\n", yylineno, s, yytext);
    //free(*root);
    fprintf(stderr, "%s\n", s);
}
