/**
 * \file ut.h
 * \brief Interface decrivant les fonctions devant etre implementees
 * ainsi que les types retournes par les tests unitaires.
 * \author LAHAYE Valentin
 * \date 28 Fevrier 2016
 */

#ifndef UT_H
#define UT_H

/**
 * \brief Le type \b ut_t est un pointeur sur une structure definie exterieurement
 * et dont les champs peuvent varier selon les besoins du test unitaire implemente.
 */
typedef struct ut_s *ut_t;

/**
 * \brief Enumeration contenant les types de retour renvoyes par la fonction
 * \b ut_run.
 */
typedef enum { UT_FAILED, /**< Le test unitaire a echoue */
	       UT_PASSED  /**< Le test unitaire est un succes */ } ut_status_t;

/**
 * \brief Fonction dont l'ensemble des instructions definissent un test unitaire
 * evaluant les donnees en entree.
 * \pre Le pointeur sur la structure de donnees en parametre doit etre different de NULL.
 * \param [in] ut Donnees sur lesquelles effectuer le test unitaire.
 * \return \b UT_FAILED : Les donnees en entree ne satisfont pas le test unitaire defini
 * par la fonction <br>
 * \b UT_PASSED : Les donnees en entree satisfont le test unitaire defini par la fonction
 */
extern ut_status_t ut_run (ut_t ut);

#endif
