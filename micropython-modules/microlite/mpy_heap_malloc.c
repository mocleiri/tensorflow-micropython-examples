/*
 * Implement Standard C memory allocation
 * using xalloc which uses the micropython heap.
 */
#include "py/mpconfig.h"
#include "py/misc.h"
#include "xalloc.h"

void *malloc (size_t size) {
    byte *data = xalloc(size);

    return data;
}

void *calloc (size_t num, size_t size) {
    return xalloc (num*size);
}

void* realloc (void* ptr, size_t size) {
    return xrealloc (ptr, size);
}
void free (void* ptr) {
    xfree(ptr);

}
void __cxa_pure_virtual()
{
    while (true) {}
}