#include <stdlib.h>
#include <string.h>
#include <word.h>

#define WORD_DEFAULT_SIZE 128

struct word_s {
    char *s_word;
    int length;
    int size;
};

word_t word_create (void) {
    word_t word  = malloc(sizeof (struct word_s));
    word->s_word = calloc(WORD_DEFAULT_SIZE, WORD_DEFAULT_SIZE * sizeof (char));
    word->length = 0;
    word->size   = WORD_DEFAULT_SIZE;
    return word;
}

void word_destroy (word_t word) {
    free(word->s_word);
    free(word);
}

void word_cat (word_t word, char c) {
    if (word->length == this->size) {
	word->size *= 2;
	word->s_word = realloc(word->s_word, word->size * sizeof (char));
    }
    word->s_word[word->length++] = c;
    word->s_word[word->length]   = '\0';
}

char *word_to_string (word_t word) {
    return strdup(word->s_word);
}
