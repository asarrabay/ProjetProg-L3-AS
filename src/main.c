#include <main.h>

int main (void) {
    yyparse();
    printf("%s\n", tree_to_xml(G_main_root, 0));
    return EXIT_SUCCESS;
}
