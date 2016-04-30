/**
 * \file label.c
 * \brief Test unitaire du lexer concernant la reconnaissance d'etiquettes.
 * \author LAHAYE Valentin
 * \date 28 Fevrier 2016
 */

#include <stdlib.h>
#include <ut/lexer.h>

int main (void) {
    return ((ut_run(UT_NEW("a'_.", 1, SYMBOL))    == UT_PASSED) &&
	    (ut_run(UT_NEW("x", 1, SYMBOL))       == UT_PASSED) &&
	    (ut_run(UT_NEW("xm", 1, SYMBOL))      == UT_PASSED) &&
	    (ut_run(UT_NEW("_a'_.", 1, SYMBOL))   == UT_PASSED) &&
	    (ut_run(UT_NEW("_xml", 1, SYMBOL))    == UT_PASSED) &&
	    (ut_run(UT_NEW("xml", 1, SYMBOL)) == UT_PASSED) &&
	    (ut_run(UT_NEW("xmL", 1, SYMBOL)) == UT_PASSED) &&
	    (ut_run(UT_NEW("XML", 1, SYMBOL)) == UT_PASSED) &&
	    (ut_run(UT_NEW("0", 1, SYMBOL))       == UT_FAILED) &&
	    (ut_run(UT_NEW("_", 1, SYMBOL))       == UT_FAILED))
	? EXIT_SUCCESS : EXIT_FAILURE ;
}
