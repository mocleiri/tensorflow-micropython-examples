#include "py/gc.h"
#include "py/obj.h"
#include <stdlib.h>
#include <stdio.h>
#include <sys/reent.h>
#include <stdarg.h>

struct _reent *_impure_ptr;

/* func can be NULL, in which case no function information is given.  */
void
__assert_func (const char *file, int line, const char *func, const char *failedexpr)
{
  printf(
	   "assertion \"%s\" failed: file \"%s\", line %d%s%s\n",
	   failedexpr, file, line,
	   func ? ", function: " : "", func ? func : "");
  abort();
  /* NOTREACHED */
}




int fputs ( const char * str, FILE * stream ) {
 // ignore the stream and just write out
 // uses puts from shared/libc/printf.c
 return puts (str);

}

int fprintf(FILE* stream, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    int ret = mp_vprintf(&mp_plat_print, fmt, ap);
    va_end(ap);
    return ret;
}


// size_t fwrite (const void * __ptr, size_t __size,
// 		      size_t __n, FILE * __s);




