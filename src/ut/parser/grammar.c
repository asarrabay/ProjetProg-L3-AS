/**
 * \file grammar.c
 * \brief Programme permettant la réalisation de tests
 * unitaires sur le parser.
 * \details Le point d'entrée du programme prend en parametre
 * le fichier contenant la grammaire a tester.
 * \author LABBE Emeric <br>
 * LAHAYE Valentin
 * \date 14 Mars 2016
 */

#include <stdlib.h>
#include <string.h>
#include <ut/parser.h>

static void usage (const char const *s_program) {
    printf("usage : %s --help | input [OPTIONS]\n\t"
       "input : path to an existing file on which run the parser\n\t"
       "--help : prompt some help for running this program correctly\n\t"
        "OPTIONS :\n\t"
        "LICIT, ILLICIT : precise if the ut should be legal or illegal\n", s_program);
    exit(EXIT_FAILURE);
}

int main (int argc, char *argv[]) {
    if (argc < 2 || argc > 3 || (strcmp(argv[1], "--help") == 0)) {
	usage(argv[0]);
    }
    ut_status_t e_status = UT_PASSED;
    if (argc == 3) {
        if (strcmp(argv[2], "ILLICIT") == 0) {
            e_status = UT_FAILED;
        } else if (strcmp(argv[2], "LICIT") != 0) {
            usage(argv[0]);
        }
    }
    FILE *fdin = fopen(argv[1], "r");
    if (fdin == NULL) {
	printf("An error occured while opening file %s !\n", argv[1]);
	usage(argv[0]);
    }
    ut_status_t status = ut_run(UT_NEW(fdin));
    fclose(fdin);
    return (status == e_status) ? EXIT_SUCCESS : EXIT_FAILURE ;
}
