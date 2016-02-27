%{
#include <stdio.h>
enum { OB = 1, CB, OSB, CSB, LABEL, EOL }; /* Enumeration temporaire contenant les tokens retournes par le lexer. Sans cette enumeration, le lexer ne compile pas ! */
%}

%option nounput
%option noinput

LABELSET ([[:alnum:]'\._])

%%

"{" { return OB; /* OPEN BRACKET */ }
"}" { return CB; /* CLOSE BRACKET */ }
"[" { return OSB; /* OPEN SQUARE BRACKET */ }
"]" { return CSB; /* CLOSE SQUARE BRACKET */ }
"/" { return EOL; /* END OF LABEL */ }

(?i:xml){LABELSET}* { /* YYABORT : Force le retour de la fonction yyparse. Cette retourne alors 1 */ }
[[:alpha:]]{LABELSET}*|_{LABELSET}+ { return LABEL; }

%%
