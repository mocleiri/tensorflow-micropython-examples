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
#ifndef __XALLOC_H__
#define __XALLOC_H__
#include <stdint.h>
void *xalloc(size_t size);
void *xalloc_try_alloc(size_t size);
void *xalloc0(size_t size);
void xfree(void *mem);
void *xrealloc(void *mem, size_t size);
#endif // __XALLOC_H__
