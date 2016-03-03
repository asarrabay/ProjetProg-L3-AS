/**
 * \file lexer.l
 * \brief Fichier contenant les regles constituant l'analyseur lexical du projet.
 * \author LAHAYE Valentin
 * \date 26 Fevier 2016
 */

%{
//#include <tokens.h>

#ifndef UT_LEXER
//#include <parser.y.h>
#endif
%}

%option nounput
%option noinput
%option noyywrap

LABELSET ([[:alnum:]'\._])

%x TEXT

%%

\"              {BEGIN TEXT;}
<TEXT>[^"]      {printf("%c", yytext[0]);}
<TEXT>\\\"      {printf("\"");}
<TEXT>\"        {BEGIN INITIAL;}


%%
