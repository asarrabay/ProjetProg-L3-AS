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
#include <machine.h>
#include <import.h>
#include <word.h>
#include <path.h>
}

%code {
void yyerror (struct closure **, char const *);
static void print_env(struct env *);
struct env *e = NULL;
}

%parse-param {struct closure ** root}

%token LABEL
%token SYMBOL
%token ILLEGAL
%token SPACES
%token CHARACTER
%token NUMBER
%token LET
%token IN
%token WHERE
%token RECURSIVE
%token FUNC
%token DIRECTORY
%token DOCUMENT
%token ARROW
%token IF
%token THEN
%token ELSE
%token TMATCH WITH END
%token DIVIDE INFEQ INF SUPEQ SUP EGAL NEGAL OU ET
%token TEMIT


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
%type <s> LABEL SYMBOL DIRECTORY DOCUMENT
%type <w> word
%type <p> path
%type <a> attributes attribute-list attribute
%type <ast> root let set block label body content word-list empt-list
%type <ast> expression expression-partielle expression-conditionnelle
%type <ast> expression-booleenne-e expression-booleenne-t expression-ari-e expression-ari-t expression-ari-f
%type <ast> lambda-function affect application match import emit
%type <patterns> patterns
%type <pattern> pattern pforest

%start start

%%


start : root    {   printf("Line :%d\n", __LINE__); print_env(e);
                    if($1 != NULL)
                        *root = process_content($1, e);
                }

      ;


root : root expression-partielle            { printf("Line :%d\n", __LINE__);($1 != NULL)?($$ = mk_forest(false, $1, $2)):($$ = $2); }
     | header                               { printf("Line :%d\n", __LINE__);$$ = NULL; }
     ;


header : LET SYMBOL affect ';' header                   { printf("Line :%d\n", __LINE__);e = process_binding_instruction($2, $3, e); }
       | LET RECURSIVE SYMBOL affect ';' header         { printf("Line :%d\n", __LINE__);e = process_binding_instruction($3, $4, e); }
| emit ';' header                                { printf("Line :%d\n", __LINE__); print_env(e); process_instruction($1, e); }
       | %empty
       ;


set : block      { printf("Line :%d\n", __LINE__);$$ = $1; }
    | label      { printf("Line :%d\n", __LINE__);$$ = $1; }
    ;


block : '{' body '}' { printf("Line :%d\n", __LINE__);$$ = $2; }
      | '{' '}'      { $$ = mk_forest(false, mk_node(), NULL); }
      ;


body : expression-partielle body { printf("Line :%d\n", __LINE__);$$ = mk_forest(false, $1, $2); }
     | expression ',' body       { printf("Line :%d\n", __LINE__);$$ = mk_forest(false, $1, $3); }
     | expression                { printf("Line :%d\n", __LINE__);$$ = mk_forest(false, $1, NULL); }
     ;


expression : expression-booleenne-e              { printf("Line :%d\n", __LINE__);$$ = $1; }
           | expression-conditionnelle           { printf("Line :%d\n", __LINE__);$$ = $1; }
           | let                                 { printf("Line :%d\n", __LINE__);$$ = $1; }
           | lambda-function                     { printf("Line :%d\n", __LINE__);$$ = $1; }
           | emit                                { printf("Line :%d\n", __LINE__);$$ = $1; }
           | match                               { printf("Line :%d\n", __LINE__);$$ = $1; }
           | import                              { printf("Line :%d\n", __LINE__);$$ = $1; }
           ;


expression-partielle : '(' expression ')'        { printf("Line :%d\n", __LINE__);$$ = $2; }
                     | set                       { printf("Line :%d\n", __LINE__);$$ = $1; }
                     | content                   { printf("Line :%d\n", __LINE__);$$ = $1; }
                     ;


expression-conditionnelle : IF expression-booleenne-e THEN expression ELSE expression { printf("Line :%d\n", __LINE__);$$ = mk_cond($2, $4, $6); }
                          ;


expression-booleenne-e : expression-booleenne-e OU expression-booleenne-t   { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(OR), $1), $3);  }
                       | expression-booleenne-e ET expression-booleenne-t   { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(AND), $1), $3); }
                       | expression-booleenne-t                             { printf("Line :%d\n", __LINE__);$$ = $1; }
                       ;


expression-booleenne-t : expression-booleenne-t INFEQ expression-ari-e      { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(LEQ), $1), $3); }
                       | expression-booleenne-t INF expression-ari-e        { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(LE), $1), $3);  }
                       | expression-booleenne-t SUPEQ expression-ari-e      { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(GEQ), $1), $3); }
                       | expression-booleenne-t SUP expression-ari-e        { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(GE), $1), $3);  }
                       | expression-booleenne-t EGAL expression-ari-e       { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(EQ), $1), $3);  }
                       | expression-booleenne-t NEGAL expression-ari-e      { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(NEQ), $1), $3); }
                       | expression-ari-e                                   { printf("Line :%d\n", __LINE__);$$ = $1; }
                       ;


expression-ari-e : expression-ari-e '+' expression-ari-t                    { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(PLUS), $1), $3);  }
                 | expression-ari-e '-' expression-ari-t                    { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(MINUS), $1), $3); }
                 | expression-ari-t                                         { printf("Line :%d\n", __LINE__);$$ = $1; }
                 ;


expression-ari-t : expression-ari-t '*' expression-ari-f                    { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(MULT), $1), $3); }
                 | expression-ari-t DIVIDE expression-ari-f                 { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(DIV), $1), $3);  }
                 | expression-ari-f                                         { printf("Line :%d\n", __LINE__);$$ = $1; }
                 ;


expression-ari-f : expression-partielle                                     { printf("Line :%d\n", __LINE__);$$ = $1; }
                 | application                                              { printf("Line :%d\n", __LINE__);$$ = $1; }
                 | NUMBER                                                   { printf("Line :%d\n", __LINE__);$$ = mk_integer($1); }
                 | '!' expression-partielle                                 { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_unaryop(NOT), $2); }
                 | '!' application                                          { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_unaryop(NOT), $2); }
                 | '!' NUMBER                                               { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_unaryop(NEG), mk_integer($2)); }
                 ;


emit : TEMIT expression-partielle expression                                { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_app(mk_binop(EMIT), $2), $3); }
     ;


let : LET SYMBOL affect IN expression                                { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_fun($2, $5), $3); }
    | '(' expression WHERE SYMBOL affect ')'                         { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_fun($4, $2), $5); }
    | LET RECURSIVE SYMBOL affect IN expression                      { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_fun($3, $6), mk_declrec($3, $6)); }
    | '(' expression WHERE RECURSIVE SYMBOL affect ')'               { printf("Line :%d\n", __LINE__);$$ = mk_app(mk_fun($5, $2), mk_declrec($5, $6)); }
    ;


affect : SYMBOL affect                                               { printf("Line :%d\n", __LINE__);$$ = mk_fun($1, $2); }
       | '=' expression                                                     { printf("Line :%d\n", __LINE__);$$ = $2; }
       | ARROW expression                                                   { printf("Line :%d\n", __LINE__);$$ = $2; }
       ;


lambda-function : FUNC affect                                           { printf("Line :%d\n", __LINE__);$$ = $2; }
                ;


application : application expression-partielle                       { printf("Line :%d\n", __LINE__);$$ = mk_app($1, $2); }
            | application SYMBOL                                     { printf("Line :%d\n", __LINE__);$$ = mk_app($1, mk_var($2) ); }
            | application NUMBER                                     { printf("Line :%d\n", __LINE__);$$ = mk_app($1, mk_integer($2) ); }
            | SYMBOL                                                 { printf("Line :%d\n", __LINE__);$$ = mk_var($1); }
            ;


label : LABEL attributes block { printf("Line :%d\n", __LINE__);$$ = mk_tree($1, false, false, false, $2, $3);    }
      | LABEL block                   { printf("Line :%d\n", __LINE__);$$ = mk_tree($1, false, false, false, NULL, $2);  }
      | LABEL attributes '/'          { printf("Line :%d\n", __LINE__);$$ = mk_tree($1, false, true, false, $2, NULL);   }
      | LABEL '/'                     { printf("Line :%d\n", __LINE__);$$ = mk_tree($1, false, true, false, NULL, NULL); }
      ;



attributes : '[' attribute-list ']' { printf("Line :%d\n", __LINE__);$$ = $2; }
           | '[' empt-list ']'      { printf("Line :%d\n", __LINE__);$$ = (struct attributes *)$2; }
           ;


attribute-list : attribute attribute-list { printf("Line :%d\n", __LINE__);$$ = $1; $1->next = $2; }
               | attribute                       { printf("Line :%d\n", __LINE__);$$ = $1; }
               ;


attribute : SYMBOL '=' content { printf("Line :%d\n", __LINE__);$$ = mk_attributes(false, mk_word($1), $3, NULL); }
          ;


content : '"' spaces word-list '"' { printf("Line :%d\n", __LINE__);$$ = $3; }
        | '"' empt-list '"'        { printf("Line :%d\n", __LINE__);$$ = $2; }
        ;


word-list : word SPACES word-list { printf("Line :%d\n", __LINE__);$$ = mk_forest(false, mk_word(word_to_string(word_cat($1, ' '))), $3); word_destroy($1); }
          | word SPACES           { printf("Line :%d\n", __LINE__);$$ = mk_forest(false, mk_word(word_to_string(word_cat($1, ' '))), NULL); word_destroy($1);                       }
          | word                  { printf("Line :%d\n", __LINE__);$$ = mk_forest(false, mk_word(word_to_string($1)), NULL); word_destroy($1);                       }
          ;


word : word CHARACTER { printf("Line :%d\n", __LINE__);$$ = word_cat($1, $2); }
     | CHARACTER      { printf("Line :%d\n", __LINE__);$$ = word_cat(word_create(), $1); }
     ;


empt-list : SPACES { printf("Line :%d\n", __LINE__);$$ = NULL; }
          | %empty { printf("Line :%d\n", __LINE__);$$ = NULL; }
          ;


spaces : SPACES
       | %empty
       ;


match : TMATCH expression WITH patterns END        { printf("Line :%d\n", __LINE__);$$ = mk_match($2, $4); }
      ;


patterns : '|' pforest ARROW expression patterns   { printf("Line :%d\n", __LINE__);$$ = mk_patterns($2, $4, $5);   }
         | '|' pforest ARROW expression            { printf("Line :%d\n", __LINE__);$$ = mk_patterns($2, $4, NULL); }
         | '|' '{' pforest '}' ARROW expression patterns   { printf("Line :%d\n", __LINE__);$$ = mk_patterns($3, $6, $7);   }
         | '|' '{' pforest '}' ARROW expression            { printf("Line :%d\n", __LINE__);$$ = mk_patterns($3, $6, NULL); }
         ;


pforest : pattern pforest                          { printf("Line :%d\n", __LINE__);$$ = mk_pforest($1, $2); }
    //    | '{' pforest '}'                          {$$ = $2; }
        | %empty                                   { printf("Line :%d\n", __LINE__);$$ = NULL; }
        ;


pattern : '_'                                      { printf("Line :%d\n", __LINE__);$$ = mk_wildcard(ANY);              }
        | LABEL '{' pattern '}'                    { printf("Line :%d\n", __LINE__);$$ = mk_ptree($1, false, $3);       }
        | LABEL '{' '}'                            { printf("Line :%d\n", __LINE__);$$ = mk_ptree($1, true, NULL);      }
        | '_' '{' pattern '}'                      { printf("Line :%d\n", __LINE__);$$ = mk_anytree(false, $3);         }
        | '_' '{' '}'                              { printf("Line :%d\n", __LINE__);$$ = mk_anytree(true, NULL);        }
        | '*' '_' '*'                              { printf("Line :%d\n", __LINE__);$$ = mk_wildcard(ANYSTRING);        }
        | '/' '_' '/'                              { printf("Line :%d\n", __LINE__);$$ = mk_wildcard(ANYFOREST);        }
        | '-' '_' '-'                              { printf("Line :%d\n", __LINE__);$$ = mk_wildcard(ANYSEQ);           }
        | SYMBOL                                   { printf("Line :%d\n", __LINE__);$$ = mk_pattern_var($1, TREEVAR);   }
        | '*' SYMBOL '*'                           { printf("Line :%d\n", __LINE__);$$ = mk_pattern_var($2, STRINGVAR); }
        | '/' LABEL '/'                           { printf("Line :%d\n", __LINE__);$$ = mk_pattern_var($2, FORESTVAR); }
        | '-' SYMBOL '-'                           { printf("Line :%d\n", __LINE__);$$ = mk_pattern_var($2, ANYVAR);    }
        ;


import : '$' path DOCUMENT ARROW SYMBOL { printf("Line :%d\n", __LINE__);PATH_SET_FILENAME($2, $3);
                                          PATH_SET_DECLNAME($2, $5);
					  $$ = mk_import($2);       }
       ;


path : top-directories DIRECTORY { printf("Line :%d\n", __LINE__);$$ = path_new($1, $2, NULL, NULL);   }
     | top-directories           { printf("Line :%d\n", __LINE__);$$ = path_new($1, NULL, NULL, NULL); }
     | DIRECTORY                 { printf("Line :%d\n", __LINE__);$$ = path_new(0, $1, NULL, NULL);    }
     | %empty                    { printf("Line :%d\n", __LINE__);$$ = path_new(0, NULL, NULL, NULL);  }
     ;


top-directories : top-directories '.' { printf("Line :%d\n", __LINE__);$$ = ++$1; }
                | '.'                 { printf("Line :%d\n", __LINE__);$$ = 1; }
                ;


%%

void yyerror (struct closure **root, char const *s) {
    printf("%p -> %p\n", (void *)root,(void *) *root );
    printf("%d: %s at %s\n", yylineno, s, yytext);
    // TODO: free du root
    //free(*root);
    fprintf(stderr, "%s\n", s);
}


static void print_env(struct env *envi) {
  while (envi!= NULL) {
    printf("%s ->", envi->var);
    fflush(stdout);

    if (envi->value != NULL)
      printf("%d\n", envi->value->value->node->num);
    else
      printf("NULL\n");
    envi = envi->next;
  }
}
