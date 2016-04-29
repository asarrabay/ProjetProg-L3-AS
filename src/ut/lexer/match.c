#include <stdlib.h>
#include <ut/lexer.h>

int main (void) {
    return ((ut_run(UT_NEW("match film with | {titre{z} /b/} -> z end", 16, TMATCH, LABEL, WITH, '|', '{', LABEL, '{', LABEL, '}', '/', LABEL, '/', '}', ARROW, LABEL, END))         == UT_PASSED) &&
            (ut_run(UT_NEW("$..a/b/bar->xml_f", 7, '$', '.', '.', DIRECTORY, DOCUMENT, ARROW, LABEL_XML)) == UT_PASSED) &&
            (ut_run(UT_NEW("$..bar->f", 6, '$', '.', '.', DOCUMENT, ARROW, LABEL))                        == UT_PASSED) &&
            (ut_run(UT_NEW("$a/bar->f", 5, '$', DIRECTORY, DOCUMENT, ARROW, LABEL))                       == UT_PASSED) &&
            (ut_run(UT_NEW("$bar->f", 4, '$', DOCUMENT, ARROW, LABEL))                                    == UT_PASSED))
        ? EXIT_SUCCESS : EXIT_FAILURE ;
}
