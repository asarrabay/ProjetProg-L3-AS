/**
 * \file tokens.h
 * \brief Fichier contenant la liste des tokens retournes par FLEX et utilises par BISON.
 * \details Le choix d'une enumeration externe est justifie par la reutilisation de ces tokens dans les tests unitaires du lexer.
 * \author LAHAYE Valentin
 * \date 28 Fevrier 2016
 */

#ifndef TOKENS_H
#define TOKENS_H

/**
 * \brief Enumeration decrivant les tokens retournes par le lexer.
 * \details La valeur de chaque membre de l'enumeration est superieur a 255 pour ne pas
 * etre confondu avec la valeur d'un caractere ASCII [0-255]. Les tokens definis apres le test
 * d'existence de la constante UT_LEXER n'existeront que dans le contexte d'un test unitaire
 * du lexer.
 */
typedef enum { OB = 256, /**< { */
	       CB, /**< } */
	       OSB, /**< [ */ 
	       CSB, /**< ] */
	       LABEL, 
	       EQL, /**< = */
	       EOL, /**< / */
	       CHARACTER
	       #ifdef UT_LEXER
	       , LABELXML
               #endif
             } tokens_t;

#endif
