%{
#include <stdio.h>
extern int yylex (void);
void yyerror (char const *);
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
               | %empty
               ;

attribute : LABEL spaces '=' spaces string
          ;

body : spaces set spaces body
     | spaces string spaces body
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
