/*
 * This file is part of the OpenMV project.
 *
 * Copyright (c) 2013-2021 Ibrahim Abdelkader <iabdalkader@openmv.io>
 * Copyright (c) 2013-2021 Kwabena W. Agyeman <kwagyeman@openmv.io>
 *
 * This work is licensed under the MIT license, see the file LICENSE for details.
 *
 * Memory allocation functions.
 *
 * Copied from github.com/openmv/openmv (master) commit: df6f77bd0646167837d0b40081b98ccca2b4591a
 *                                          Commit Date: Tue Nov 9 16:55:44 2021 +0200
 *
 */
#include <string.h>
#include "py/runtime.h"
#include "py/gc.h"
#include "py/mphal.h"
#include "xalloc.h"

NORETURN static void xalloc_fail(size_t size)
{
    mp_raise_msg_varg(&mp_type_MemoryError,
            MP_ERROR_TEXT("memory allocation failed, allocating %u bytes"), (uint)size);
}

// returns null pointer without error if size==0
void *xalloc(size_t size)
{
    void *mem = gc_alloc(size, false);
    if (size && (mem == NULL)) {
        xalloc_fail(size);
    }
    return mem;
}

// returns null pointer without error if size==0
void *xalloc_try_alloc(size_t size)
{
    return gc_alloc(size, false);
}

// returns null pointer without error if size==0
void *xalloc0(size_t size)
{
    void *mem = gc_alloc(size, false);
    if (size && (mem == NULL)) {
        xalloc_fail(size);
    }
    memset(mem, 0, size);
    return mem;
}

// returns without error if mem==null
void xfree(void *mem)
{
    gc_free(mem);
}

// returns null pointer without error if size==0
// allocs if mem==null and size!=0
// frees if mem!=null and size==0
void *xrealloc(void *mem, size_t size)
{
    mem = gc_realloc(mem, size, true);
    if (size && (mem == NULL)) {
        xalloc_fail(size);
    }
    return mem;
}
