// suggested in: https://alex-robenko.gitbook.io/bare_metal_cpp/compiler_output/abstract_classes
// Implemented using xalloc functions from openmv.
/*
 *
 */
#include <cstdlib>

#include "malloc.h"

void * operator new(unsigned int n)
{
  void * const p = malloc(n);
  // handle p == 0
  return p;
}

void operator delete(void *p)
{
  free(p);
}

void operator delete(void *p, size_t size)
{
  free(p);
}
