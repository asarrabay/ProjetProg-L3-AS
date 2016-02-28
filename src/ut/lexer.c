#include <ut/lexer.h>

typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern YY_BUFFER_STATE yy_scan_string(char *);
extern tokens_t yylex(void);
extern void yy_delete_buffer(YY_BUFFER_STATE);

ut_status_t ut_run (ut_t ut) {
    YY_BUFFER_STATE input = yy_scan_string(ut->s_input);
    tokens_t t;
    int i = -1;
    while ((t = yylex()) && (++i < ut->size) && (t == ut->sa_output[i]));
    yy_delete_buffer(input);
    return ((i == ut->size) && (t == (tokens_t)0)) ? UT_PASSED : UT_FAILED;
}
