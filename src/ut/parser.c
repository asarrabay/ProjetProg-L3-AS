/**
 * \file parser.c
 * \brief Fichier contenant l'implementation de l'interface parser.h
 * \author LAHAYE Valentin
 * \date 14 Mars 2016
 */

#include <ut/parser.h>
#include <lexer.h>
#include <parser.h>

ut_status_t ut_run (ut_t ut) {
    tree_t document = NULL;
    yyin = ut->p_input;
    int status = yyparse(&document);
    if (!(document == NULL)) {
	tree_destroy(document);
    }
    return (status == 0) ? UT_PASSED : UT_FAILED ;
}
