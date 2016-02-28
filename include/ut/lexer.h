#ifndef UT_LEXER_H
#define UT_LEXER_H

#include <ut.h>
#include <tokens.h>

#define UT_NEW(INPUT, SIZE, ...)					\
    &(struct ut_s){ .s_input = (INPUT),					\
	            .sa_output = { __VA_ARGS__ },	 		\
	            .size = (SIZE) }

struct ut_s {
    char     *s_input;
    tokens_t  sa_output[61];
    int       size;
};

#endif
