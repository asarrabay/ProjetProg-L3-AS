#include <ut/lexer.h>

typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern YY_BUFFER_STATE yy_scan_string(char *);
extern int yylex(void);
extern void yy_delete_buffer(YY_BUFFER_STATE);

ut_status_t ut_run (ut_t ut) {
    YY_BUFFER_STATE input = yy_scan_string(ut->s_input);
    int i = -1;
    while ((++i < ut->size) && ((tokens_t)yylex() == ut->sa_output[i]));
    ut_status_t status = ((i == ut->size) && (yylex() == 0)) ? UT_PASSED : UT_FAILED ;
    yy_delete_buffer(input);
    return status;
}
