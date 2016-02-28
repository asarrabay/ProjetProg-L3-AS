%{
#include <tokens.h>

#ifndef UT_LEXER
#include <parser.y.h>
#endif
%}

%option nounput
%option noinput
%option noyywrap

LABELSET ([[:alnum:]'\._])

%%

"{" { return OB;  }
"}" { return CB;  }
"[" { return OSB; }
"]" { return CSB; }
"/" { return EOL; }

(?i:xml){LABELSET}*                 { 
                                      #ifdef UT_LEXER
                                          return LABELXML;
                                      #else
                                          /* YYABORT : Force le retour de la fonction yyparse. Cette derniere retourne alors 1 */
                                      #endif
                                    }
[[:alpha:]]{LABELSET}*|_{LABELSET}+ { return LABEL; }

%%
