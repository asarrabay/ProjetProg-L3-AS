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

LABELSET ([[:alnum:]'._])

%x STRING
%x RETSPACES
%x IMPORT

%%

<IMPORT>\.                      { printf("Line :%d / text : %s\n", __LINE__, yytext);return '.'; }
<IMPORT>[^.][^/]*[/]([^/]+[/])* {
                                  #ifndef UT_LEXER
                                      yylval.s = strdup(yytext);
                                  #endif
                                  return DIRECTORY;
                                }
<IMPORT>[^./][^/]-[>]           {
                                  BEGIN INITIAL;
                                  yyless(yyleng - 2);
                                  #ifndef UT_LEXER
                                      yylval.s = strdup(yytext);
                                  #endif
                                  return DOCUMENT;
                                }

<STRING>[[:space:]]+ { printf("Line :%d / text : %s\n", __LINE__, yytext);return SPACES; }
<STRING>\\\\         { printf("Line :%d / text : %s\n", __LINE__, yytext);
                       #ifndef UT_LEXER
                           yylval.c = '\\';
                       #endif
                       return CHARACTER;
                     }
<STRING>\\\"         { printf("Line :%d / text : %s\n", __LINE__, yytext);
                       #ifndef UT_LEXER
                           yylval.c = '"';
                       #endif
                       return CHARACTER;
                     }
<STRING>[^"]         { printf("Line :%d / text : %s\n", __LINE__, yytext);
                       #ifndef UT_LEXER
                           yylval.c = yytext[0];
                       #endif
                       return CHARACTER;
                     }
<STRING>\"           { printf("Line :%d / text : %s\n", __LINE__, yytext);
                       #ifndef UT_LEXER
                           BEGIN RETSPACES;
                       #else
                           BEGIN INITIAL;
                       #endif
                       return '"';
                     }

<RETSPACES>[[:space:]]+ { printf("Line :%d / text : %s\n", __LINE__, yytext);BEGIN INITIAL; return SPACES; }
<RETSPACES>.            { printf("Line :%d / text : %s\n", __LINE__, yytext);BEGIN INITIAL; yyless(0); }

in           { printf("Line :%d / text : %s\n", __LINE__, yytext);return IN; }
if           { printf("Line :%d / text : %s\n", __LINE__, yytext);return IF; }
let          { printf("Line :%d / text : %s\n", __LINE__, yytext);return LET; }
then         { printf("Line :%d / text : %s\n", __LINE__, yytext);return THEN; }
else         { printf("Line :%d / text : %s\n", __LINE__, yytext);return ELSE; }
where        { printf("Line :%d / text : %s\n", __LINE__, yytext);return WHERE; }
-\>          { printf("Line :%d / text : %s\n", __LINE__, yytext);return ARROW; }
fun          { printf("Line :%d / text : %s\n", __LINE__, yytext);return FUNC; }
rec          { printf("Line :%d / text : %s\n", __LINE__, yytext);return RECURSIVE; }
match        { printf("Line :%d / text : %s\n", __LINE__, yytext);return TMATCH; }
with         { printf("Line :%d / text : %s\n", __LINE__, yytext);return WITH; }
end          { printf("Line :%d / text : %s\n", __LINE__, yytext);return END; }
emit         { printf("Line :%d / text : %s\n", __LINE__, yytext);return TEMIT; }

"||"         { printf("Line :%d / text : %s\n", __LINE__, yytext);return OU; }
"&&"         { printf("Line :%d / text : %s\n", __LINE__, yytext);return ET; }
"<"          { printf("Line :%d / text : %s\n", __LINE__, yytext);return INF; }
">"          { printf("Line :%d / text : %s\n", __LINE__, yytext);return SUP; }
"=="         { printf("Line :%d / text : %s\n", __LINE__, yytext);return EGAL; }
"!="         { printf("Line :%d / text : %s\n", __LINE__, yytext);return NEGAL; }
"<="         { printf("Line :%d / text : %s\n", __LINE__, yytext);return INFEQ; }
">="         { printf("Line :%d / text : %s\n", __LINE__, yytext);return SUPEQ; }
"//"         { printf("Line :%d / text : %s\n", __LINE__, yytext);return DIVIDE; }


(?i:xml){LABELSET}*                 { printf("Line :%d / text : %s\n", __LINE__, yytext);
                                        #ifndef UT_LEXER
                                            BEGIN RETSPACES;
                                            yylval.s = strdup(yytext);
                                        #endif
                                        return LABEL_XML;
                                    }

[[:alpha:]]{LABELSET}*|_{LABELSET}+ { printf("Line :%d / text : %s\n", __LINE__, yytext);
                                      #ifndef UT_LEXER
                                          BEGIN RETSPACES;
                                          yylval.s = strdup(yytext);
                                      #endif
                                      return LABEL;
                                    }

\"           { printf("Line :%d / text : %s\n", __LINE__, yytext);BEGIN STRING; return '"'; }
\]           { printf("Line :%d / text : %s\n", __LINE__, yytext);BEGIN RETSPACES; return ']'; }
\$           { printf("Line :%d / text : %s\n", __LINE__, yytext);BEGIN IMPORT; return '$'; }

[[:digit:]]+ {
               #ifndef UT_LEXER
                   yylval.n = atoi(yytext);
               #endif
               return NUMBER;
             }

[[:space:]]+ {}
.            { printf("Line :%d / text : %s\n", __LINE__, yytext);return yytext[0]; }

%%
