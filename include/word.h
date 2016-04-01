#ifndef WORD_H
#define WORD_H

typedef struct word_s *word_t;

extern word_t  word_create (void);
extern void    word_destroy (word_t);
extern word_t  word_cat (word_t, char);
extern char   *word_to_string (word_t);

#endif

