/**
 * \file grammar.c
 * \brief Programme permettant la réalisation de tests
 * unitaires sur le parser.
 * \details Le point d'entrée du programme prend en parametre
 * le fichier contenant la grammaire a tester.
 * \author LAHAYE Valentin
 * \date 14 Mars 2016
 */

#include <stdlib.h>
#include <string.h>
#include <ut/parser.h>

static void usage (const char const *s_program) {
    printf("usage : %s --help | input\n\t"
	   "input : path to an existing file on which run the parser\n\t"
	   "--help : prompt some help for running this program correctly\n", s_program);
    exit(EXIT_FAILURE);
}

int main (int argc, char *argv[]) {
    if (argc < 2 || (strcmp(argv[1], "--help") == 0)) {
	usage(argv[0]);
    }
    FILE *p_input = fopen(argv[1], "r");
    if (p_input == NULL) {
	printf("An error occured while opening file %s !\n", argv[1]);
	usage(argv[0]);
    }
    ut_status_t status = ut_run(UT_NEW(p_input));
    fclose(p_input);
    return (status == UT_PASSED) ? EXIT_SUCCESS : EXIT_FAILURE ;
}
