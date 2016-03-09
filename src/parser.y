%{
#include <stdio.h>
extern int yylex (void);
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

set : spaces '{' body '}' spaces
    | spaces label spaces
    ;

label : LABEL attributes spaces '{' body '}'
      | LABEL '{' body '}'
      | LABEL attributes '/'
      | LABEL '/'
      ;

attributes : '[' spaces attribute_list spaces ']'
           ;

attribute_list : attribute SPACES attribute_list
               | attribute
               | %empty
               ;

attribute : LABEL spaces '=' string
          ;

body : set body
     | string body
     | %empty
     ;

string : spaces '"' characters '"' spaces
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
