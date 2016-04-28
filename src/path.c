#include <stdlib.h>
#include <path.h>

struct path *path_new (int n, char *s_directory, char *s_filename, char *s_declname) {
    struct path *path      = malloc(sizeof (struct path));
    struct dir  *directory = malloc(sizeof (struct dir));
    struct dir  *filename  = malloc(sizeof (struct dir));
    struct dir  *declname  = malloc(sizeof (struct dir));
    path->n          = n;
    path->dir        = directory;
    directory->descr = DIR;
    directory->str   = s_directory;
    filename->descr  = FILENAME;
    filename->str    = s_filename;
    declname->descr  = DECLNAME;
    declname->str    = s_declname;
    return path;
}

void path_destroy (struct path *path) {
    struct dir *directory = path->dir;
    struct dir *filename  = directory->dir;
    struct dir *declname  = filename->dir;
    free(declname->str);
    free(filename->str);
    free(directory->str);
    free(declname);
    free(filename);
    free(directory);
    free(path);
}
