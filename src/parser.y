/**
 * \file parser.y
 * \brief Fichier contenant les regles constituant l'analyseur syntaxique du projet.
 * \author LABBE Emeric <br>
 * LAHAYE Valentin <br>
 * PARPAITE Thibault <br>
 * SARRABAYROUSE Alexis
 * \date 26 Fevrier 2016
 */

%{
#include <stdio.h>
#include <lexer.h>
void yyerror (char const *);
%}

%token LABEL
%token LABEL_XML
%token SPACES
%token CHARACTER

%union {
    char c;
    struct {
	char *s_label;
	int length;
    } label;
    tree t;
    attributes att;
}

%type <c> CHARACTER
%type <label> LABEL
%type <t> set label
%type <att> attribute attribute_list attributes          

%start root

%%

root : root set
     | %empty
     ;

set : '{' body '}'     { $$ = $2; }
    | label     { $$ = $1; }
    ;

label : LABEL attributes spaces '{' body '}'     { $$ = tree_create(yyval.label.s_labal, false, false, tree, $2, $5, NULL); }
        |       LABEL '{' body '}'     { $$ = tree_create(yyval.label.s_labal, false, false, tree, NULL, $3, NULL); }
        |       LABEL attributes '/'     { $$ = tree_create(yyval.label.s_label, false, false, tree, $2, NULL, NULL; }
        |       LABEL '/'     { $$ = tree_create(yyval.label.s_label, true, false, word, NULL, NULL, NULL); }
      ;

attributes : '[' attribute_list ']'     { $$ = $2; }
           ;

attribute_list : attribute SPACES attribute_list     { attributes_add_tolist($1, $3);
                                                       $$ = $1; }
               | attribute     { $$ = $1; }
               | %empty
               ;

attribute : LABEL spaces '=' string     { $$ = attributes_create(yyval.label.s_label, $4); }
          ;

 body : set body     { tree_add_brother($1, $2); $$ = $1; }
     | string spaces body     { tree_add_brother($1, $3); $$ = $1; }
     | %empty
     ;

string : '"' characters '"'     { $$ = $2; }
       ;

characters : characters CHARACTER     /* TODO retourner mot par mot et pas car par car... */
           | %empty
           ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (char const *s) {
    fprintf(stderr, "%s\n", s);
}
