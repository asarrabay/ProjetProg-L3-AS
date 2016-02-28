#ifndef TOKENS_H
#define TOKENS_H

typedef enum { OB = 256, CB, OSB, CSB, LABEL, EQL, EOL, QUOTE, CHARACTER
	       #ifdef UT_LEXER
	       , LABELXML
               #endif
             } tokens_t;

#endif
