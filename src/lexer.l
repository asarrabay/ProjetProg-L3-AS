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
#include <tree.h>
#include <parser.h>
#else
#include <tokens.h>
#endif
%}

%option nounput noinput noyywrap

LABELSET ([[:alnum:]'\._])

%x STRING
%x RETSPACES

%%

<INITIAL,RETSPACES>\" {   BEGIN STRING; 
                          return '"';  
                      }

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

<STRING>[:space:]+ { ; }

<STRING>[^\"[:space:]]+/\" {
                  #ifndef UT_LEXER         
                      yylval.t = tree_create(strdup(yytext), true, false, word, NULL, NULL, NULL);
                  #endif
                  return WORD;
              }

<STRING>[^\"[:space:]]+ {
                  #ifndef UT_LEXER
                      yylval.t = tree_create(strdup(yytext), true, true, word, NULL, NULL, NULL);
                  #endif
                  return WORD;
              }

<STRING>\"    {
                  #ifndef UT_LEXER
                      BEGIN RETSPACES;
                  #else
                      BEGIN INITIAL;
                  #endif
                  return '"';
              }

(?i:xml){LABELSET}*                 {   return LABEL_XML;   }
[[:alpha:]]{LABELSET}*|_{LABELSET}+ {
                                        #ifndef UT_LEXER
                                            BEGIN RETSPACES;
                                            yylval.str = strdup(yytext);
                                        #endif
                                        return LABEL;
                                    }

\] {   BEGIN RETSPACES; return ']';   }

<RETSPACES>[[:space:]]+ {   BEGIN INITIAL; 
                            return SPACES;       
                        }
<RETSPACES>\]           {   return ']';   }
<RETSPACES>.            {   BEGIN INITIAL; 
                            return yytext[0];    
                        }

[[:space:]]+  { }
.             {   return yytext[0];   }

%%
