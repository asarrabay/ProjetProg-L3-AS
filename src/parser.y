%{
#include <tokens.h>
%}

%token LABEL
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

root : 		set root
		| 	%empty
		;

set : 		'{' body '}'
		| 	label
		;

label : 	LABEL attributes space '{' body '}'
		| 	LABEL '{' body '}'
		| 	LABEL attributes '/'
		| 	LABEL '/'
		;

attributes : 	'[' attribute_list ']'
				;

attribute_list : 	attribute space attribute_list
				|	%empty
				;

attribute : LABEL space '=' space string
			;

body : 		set body
		| 	string body
		| 	%empty
		;

string : '"' characters '"'
;

characters :	CHARACTER characters
			| 	%empty
			;

space :		SPACES
		|	%empty
		;

%%
