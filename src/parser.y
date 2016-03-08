%{
#include <stdio.h>
void yyerror (char const *);
extern int yylex (void);
%}

%token LABEL LABEL_XML
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

%%

root : set root
     | %empty
     ;

set : '{' body '}'
    | label
    ;

label : LABEL attributes spaces '{' body '}'
      | LABEL '{' body '}'
      | LABEL attributes '/'
      | LABEL '/'
      ;

attributes : '[' attribute_list ']'
           ;

attribute_list : attribute spaces attribute_list
               | %empty
               ;

attribute : LABEL spaces '=' spaces string
          ;

body : set body
     | string body
     | %empty
     ;

string : '"' characters '"'
       ;

characters : CHARACTER characters
           | %empty
           ;

spaces : SPACES
       | %empty
       ;

%%

void yyerror (char const *s) {
    fprintf (stderr, "%s\n", s);
}
