#include "py/gc.h"
#include "py/obj.h"
#include <stdlib.h>
#include <stdio.h>
#include <sys/reent.h>

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

// I need to store the buffer as a root pointer
// can I initialize the buffer from the bootstrapping of the microlite module?
// can I add an initialization method to the module?
//
//void *gc_alloc(size_t n_bytes, unsigned int alloc_flags);
//void gc_free(void *ptr); // does not call finaliser
//size_t gc_nbytes(const void *ptr);
//void *gc_realloc(void *ptr, size_t n_bytes, bool allow_move);
void *malloc (size_t size) {
    byte *data = m_new(byte, size);

//    self->tensor_area = mp_obj_new_bytearray_by_ref (tensor_area_len, tensor_area_buffer);
    return data;
}

void *calloc (size_t num, size_t size) {
    return malloc (num*size);
}

void* realloc (void* ptr, size_t size) {
// should be improved
    return malloc (size);
}
void free (void* ptr) {

}

