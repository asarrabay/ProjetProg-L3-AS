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

%option nounput noinput noyywrap

LABELSET ([[:alnum:]'\._])

%x STRING

%%

[[:space:]]+  {   return SPACES;   }

\"            {   BEGIN STRING; return '"';   }
<STRING>\\\\  {
                  #ifndef UT_LEXER
                      yylval.c = '\\';
                  #endif
                  return CHARACTER;
              }
<STRING>\\\"  {
                  #ifndef UT_LEXER
                      yylval.c = '"';
                  #endif
                  return CHARACTER;
              }
<STRING>[^\"] {
                  #ifndef UT_LEXER
                      yylval.c = yytext[0];
                  #endif
                  return CHARACTER;
              }
<STRING>\"    {   BEGIN INITIAL; return '"';   }

(?i:xml){LABELSET}*                 {   return LABEL_XML;   }
[[:alpha:]]{LABELSET}*|_{LABELSET}+ {
                                        #ifndef UT_LEXER
                                            yylval.label.s_label = strdup(yytext);
                                            yylval.label.length = yyleng;
                                        #endif
                                        return LABEL;
                                    }

. {   return yytext[0];   }

%%
