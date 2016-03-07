%{
#include <tokens.h>
%}

%token LABEL
%token SPACES
%token CHARACTER

%%

root : set root
| %empty
;

set : '{' body '}'
| label
;

label : LABEL attributes '{' body '}'
| LABEL attributes '{' body '}' '/'
| LABEL '{' body '}'
| LABEL '{' body '}' '/'
| LABEL attributes '/'
| LABEL '/'
;

attributes : '[' attribute_list ']'
;

attribute_list : attribute SPACES attribute_list
| attribute
| %empty
;

attribute : LABEL '=' string
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

%%
