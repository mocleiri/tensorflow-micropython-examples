/*
 * Copyright (c) 2017-2018, Arm Limited.
 * SPDX-License-Identifier: MIT
 */

#include <math.h>
#include <stdint.h>

float powf(float x, float y)
{
    return pow((double)x, (double)y);
}