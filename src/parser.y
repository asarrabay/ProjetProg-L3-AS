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
}

%type <c> CHARACTER
%type <label> LABEL

%start root

%%

root : root set
     | %empty
     ;

set : spaces '{' body '}'
    | spaces label
    ;

label : LABEL attributes spaces '{' body '}'
      | LABEL '{' body '}'
      | LABEL attributes '/'
      | LABEL '/'
      ;

attributes : '[' attribute_list ']'
           ;

attribute_list : attribute SPACES attribute_list
               | attribute
               | spaces
               ;

attribute : LABEL spaces '=' string
          ;

body : set body
     | string body
     | spaces
     ;

string : spaces '"' characters '"'
       ;

characters : characters CHARACTER
           | %empty
           ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (char const *s) {
    fprintf(stderr, "%s\n", s);
}
