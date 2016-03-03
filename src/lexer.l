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

LABELSET    ([[:alnum:]'\._])
LABEL       [[:alpha:]]{LABELSET}*|_{LABELSET}+

%x ATTR

%x TEXT

%%

\[                      {   printf("catch : %c\n", yytext[0]);
                            BEGIN ATTR;}
<ATTR>{LABEL}           {   printf("label attr : %s\n", yytext);}
<ATTR>=                 {   printf("=\n");}
<ATTR>\"[^"]*\"         {   printf("val = %s\n", yytext);}
<ATTR>[[:space:]]*      {}
<ATTR>\][[:space:]]+\/  {   printf("La YAPAboN\n");}
<ATTR>\][[:space:]]*    {   printf("catch : %c\n", yytext[0]);
                            BEGIN INITIAL;}


\"              {BEGIN TEXT;}
<TEXT>[^"]      {printf("%c", yytext[0]);}
<TEXT>\\\"      {printf("\"");}
<TEXT>\"        {BEGIN INITIAL;}


[{}/]   {printf("catch : %c\n", yytext[0]);}

(?i:xml){LABELSET}*                 { 
                                      #ifdef UT_LEXER
                                          printf("return LABELXML;");
                                      #else
                                          /* YYABORT : Force le retour de la fonction yyparse. Cette derniere retourne alors 1 */
                                      #endif
                                    }

{LABEL} { printf("return LABEL; %s\n", yytext);  }

.   {printf("NON VALIDE\n");}

%%
