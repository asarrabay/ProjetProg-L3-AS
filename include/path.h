#ifndef PATH_H
#define PATH_H

#define PATH_SET_DIRECTORY(path, directory) (path)->dir->str = (directory)
#define PATH_SET_FILENAME(path, filename) (path)->dir->dir->str = (filename)
#define PATH_SET_DECLNAME(path, declname) (path)->dir->dir->dir->str = (declname)

enum descr { DIR, FILENAME, DECLNAME };

struct dir {
    char *str;
    enum descr descr;
    struct dir *dir;
};

struct path {
    int n;
    struct dir *dir;
};

struct path *path_new     (int, char *, char *, char *);
void         path_destroy (struct path *);

#endif
