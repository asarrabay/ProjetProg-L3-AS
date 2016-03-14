#include <ut/parser.h>
#include <lexer.h>
#include <parser.h>

ut_status_t ut_run (ut_t ut) {
    yyin = ut->p_input;
    return (yyparse() == 0) ? UT_PASSED : UT_FAILED ;
}
