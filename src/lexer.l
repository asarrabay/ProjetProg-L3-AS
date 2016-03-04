/**
 * \file lexer.l
 * \brief Fichier contenant les regles constituant l'analyseur lexical du projet.
 * \author LAHAYE Valentin
 * \date 26 Fevier 2016
 */

%{
#include <tokens.h>

#ifndef UT_LEXER
#include <parser.y.h>
#endif
%}

%option nounput
%option noinput
%option noyywrap

LABELSET    ([[:alnum:]'\._])
LABEL       [[:alpha:]]{LABELSET}*|_{LABELSET}+

%x STRING

%%

\"             { BEGIN STRING; return QUOTE; }
<STRING>[^\"]  { return CHARACTER; }
<STRING>"\\\"" { return CHARACTER; }
<STRING>\"     { BEGIN INITIAL; return CHARACTER; }

(?i:xml){LABELSET}*                 { 
                                      #ifdef UT_LEXER
                                          return LABELXML;
                                      #else
                                          /* YYABORT : Force le retour de la fonction yyparse. Cette derniere retourne alors 1 */
                                      #endif
                                    }
{LABEL} { return LABEL; }

%%
