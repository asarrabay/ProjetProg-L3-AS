#ifndef UT_PARSER_H
#define UT_PARSER_H

#include <stdio.h>
#include <ut.h>

#define UT_NEW(INPUT)				\
    &(struct ut_s){ .p_input = (INPUT) }

struct ut_s {
    FILE *p_input;
};

#endif
