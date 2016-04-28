#include <stdlib.h>
#include <ut/lexer.h>

int main (void) {
    return ut_run(UT_NEW("42", 1, NUMBER)) == UT_PASSED
        ? EXIT_SUCCESS : EXIT_FAILURE ;
}
