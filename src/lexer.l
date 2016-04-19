
/**
 * \file lexer.l
 * \brief Fichier contenant les regles constituant l'analyseur lexical du projet.
 * \author LABBE Emeric <br>
 * LAHAYE Valentin <br>
 * PARPAITE Thibault <br>
 * SARRABAYROUSE Alexis
 * \date 26 Fevrier 2016
 */

%{
#ifndef UT_LEXER
#include <string.h>
#include <parser.h>
#else
#include <tokens.h>
#endif
%}

%option nounput noinput

LABELSET ([[:alnum:]'\._])

%x STRING
%x RETSPACES

%%

let          {   return LET;         }
in           {   return IN;          }
where        {   return WHERE;       }
rec          {   return RECURSIVE;   }
fun          {   return FUNCTION;    }
->           {   return ASSOC;       }
if           {   return IF;          }
then         {   return THEN;        }
else         {   return ELSE;        }

"<="         {   return INFEQ;         }
"<"          {   return INF;          }
">="         {   return SUPEQ;         }
">"          {   return SUP;          }
"=="         {   return EGAL;          }
"||"         {   return OU;          }
"&&"         {   return ET;         }

(?i:xml){LABELSET}*                 {   return LABEL_XML;   }
[[:alpha:]]{LABELSET}*|_{LABELSET}+ {
                                        #ifndef UT_LEXER
                                            BEGIN RETSPACES;
                                            yylval.s = strdup(yytext);
                                        #endif
                                        return LABEL;
                                    }

\"           {   BEGIN STRING; return '"';      }
\]           {   BEGIN RETSPACES; return ']';   }

[[:space:]]+ { }

. {   return yytext[0];   }

<STRING>[[:space:]]+ {   return SPACES;   }

<STRING>\\\\         {
                         #ifndef UT_LEXER
                             yylval.c = '\\';
                         #endif
                         return CHARACTER;
                     }

<STRING>\\\"         {
                         #ifndef UT_LEXER
                             yylval.c = '"';
                         #endif
                         return CHARACTER;
                     }

<STRING>[^\"]        {
                         #ifndef UT_LEXER
                             yylval.c = yytext[0];
                         #endif
                         return CHARACTER;
                     }

<STRING>\"           {
                         #ifndef UT_LEXER
                             BEGIN RETSPACES;
                         #else
                             BEGIN INITIAL;
                         #endif
                         return '"';
                     }

<RETSPACES>[[:space:]]+ {   BEGIN INITIAL; return SPACES;   }
<RETSPACES>.            {   BEGIN INITIAL; yyless(0);       }

%%
