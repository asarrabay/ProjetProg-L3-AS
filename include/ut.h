#ifndef UT_H
#define UT_H

typedef struct ut_s *ut_t;
typedef enum { UT_FAILED, UT_PASSED } ut_status_t;

extern ut_status_t ut_run (ut_t);

#endif
