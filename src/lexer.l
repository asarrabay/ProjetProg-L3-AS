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

\"             {   BEGIN STRING; return '"';      }
\]             {   BEGIN RETSPACES; return ']';   }
where          {   return WHERE;                  }
let            {   return LET;                    }
in             {   return IN;                     }
[[:space:]]+   { }

(?i:xml){LABELSET}*                 {   return LABEL_XML;   }

[[:alpha:]]{LABELSET}*|_{LABELSET}+ {
                                        #ifndef UT_LEXER
                                            BEGIN RETSPACES;
                                            yylval.s = strdup(yytext);
                                        #endif
                                        return LABEL;
                                    }

. {   return yytext[0];   }

<STRING>[[:space:]]+ { }

<STRING>[^\"[[:space:]]]+/\"   {
                                    #ifndef UT_LEXER
                                       yylval.t = tree_create(strdup(yytext), true, false, word, NULL, NULL, NULL);
                                    #endif
                                    return WORD;
                               }

<STRING>[^\"[[:space:]]]+      {
                                    #ifndef UT_LEXER
                                       yylval.t = tree_create(strdup(yytext), true, true, word, NULL, NULL, NULL);
                                    #endif
                                    return WORD;
                                }

<STRING>\"                      {
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
