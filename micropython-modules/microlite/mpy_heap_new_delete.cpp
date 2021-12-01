// suggested in: https://alex-robenko.gitbook.io/bare_metal_cpp/compiler_output/abstract_classes
// Implemented using xalloc functions from openmv.
/*
 *
 */
#include <cstdlib>
#include "xalloc.h"


void * operator new(std::size_t n)
{
  void * const p = xalloc((size_t)n);
  // handle p == 0
  return p;
}

void operator delete(void *p)
{
  xfree(p);
}

void operator delete(void *p, std::size_t size)
{
  xfree(p);
}
