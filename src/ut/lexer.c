/**
 * \file lexer.c
 * \brief Fichier contenant l'implementation de l'interface lexer.h
 * \author LAHAYE Valentin
 * \date 28 Fevrier 2016
 */

#include <ut/lexer.h>
#include <lexer.h>

ut_status_t ut_run (ut_t ut) {
    YY_BUFFER_STATE input = yy_scan_string(ut->s_input);
    int i = -1;
    while ((++i < ut->size) && ((tokens_t)yylex() == ut->sa_output[i]));
    ut_status_t status = ((i == ut->size) && (yylex() == 0)) ? UT_PASSED : UT_FAILED ;
    yy_delete_buffer(input);
    return status;
}
