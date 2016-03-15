/**
 * \file parser.h
 * \brief Interface decrivant le contenu de la structure ut_s
 * dans le cadre d'un test unitaire du parser.
 * \author LAHAYE Valentin
 * \date 14 Mars 2016
 */

#ifndef UT_PARSER_H
#define UT_PARSER_H

#include <stdio.h>
#include <ut.h>

/**
 * \brief Cree une structure ut_s sur la pile, remplit ses champs avec les donnees 
 * passees en parametre et retourne son adresse.
 * \param [in] INPUT Fichier sur lequel tester le parser.
 */
#define UT_NEW(INPUT)				\
    &(struct ut_s){ .p_input = (INPUT) }

/**
 * \brief Structure contenant les donnees necessaires lors d'un test unitaire du parser.
 */
struct ut_s {
    FILE *p_input;
};

#endif
