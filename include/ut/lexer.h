/**
 * \file lexer.h
 * \brief Interface decrivant le contenu de la structure ut_s
 * dans le cadre d'un test unitaire du lexer.
 * \author LAHAYE Valentin
 * \date 28 Fevrier 2016
 */

#ifndef UT_LEXER_H
#define UT_LEXER_H

#include <ut.h>
#include <tokens.h>

/**
 * \brief Cree une structure ut_s sur la pile, remplit ses champs avec les donnees 
 * passees en parametre et retourne son adresse.
 * \param [in] INPUT Chaine de caracteres a tester.
 * \param [in] SIZE Longueur de la sequence attendue en sortie du lexer.
 * \param [in] ... Sequence de tokens attendue en sortie du lexer.
 */
#define UT_NEW(INPUT, SIZE, ...)					\
    &(struct ut_s){ .s_input = (INPUT),					\
	            .sa_output = { __VA_ARGS__ },	 		\
	            .size = (SIZE) }

/**
 * \brief Structure contenant les donnees necessaires lors d'un test unitaire du lexer.
 */
struct ut_s {
    char     *s_input; /**< Chaine de caracteres a tester. */
    tokens_t  sa_output[61]; /**< Sequence de tokens attendue en sortie du lexer. */
    int       size; /**< Nombre d'elements contenus dans la sequence. */
};

#endif
