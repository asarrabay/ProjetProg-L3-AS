#include <main.h>

int main (void) {
    yyparse();
    printf("%s\n", tree_to_xml(G_main_root));
    return EXIT_SUCCESS;
}
