#include <stdlib.h>
#include <ut/lexer.h>


int main (void) {
    return (ut_run(UT_NEW("\"string\"", 8, (tokens_t)'"', CHARACTER, CHARACTER, CHARACTER, CHARACTER, CHARACTER, CHARACTER, (tokens_t)'"')) && ut_run(UT_NEW("\"\"\"", 3, (tokens_t)'"', CHARACTER, (tokens_t)'"'))) ? EXIT_SUCCESS : EXIT_FAILURE ;
}
