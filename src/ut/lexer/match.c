#include <stdlib.h>
#include <ut/lexer.h>

int main (void) {
  return ((ut_run(UT_NEW("match film with | {titre{z} /b/} -> z end", 16, TMATCH, SYMBOL, WITH, '|', '{', LABEL, '{', SYMBOL, '}', '/', LABEL, '/', '}', ARROW, SYMBOL, END))         == UT_PASSED))
        ? EXIT_SUCCESS : EXIT_FAILURE ;
}
