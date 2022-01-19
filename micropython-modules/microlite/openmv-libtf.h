/* This file is part of the OpenMV project.
 * Copyright (c) 2013-2019 Ibrahim Abdelkader <iabdalkader@openmv.io> & Kwabena W. Agyeman <kwagyeman@openmv.io>
 * This work is licensed under the MIT license, see the file LICENSE for details.
 * 
 * The C -> C++ micropython -> tensorflow micro c++ api bridging code originated with the OpenMV 
 * project although it is now quite different.
 * 
 */

#ifndef __OPENMV_LIBTF_H
#define __OPENMV_LIBTF_H

#ifdef __cplusplus
extern "C" {
#endif


#include "tensorflow/lite/c/common.h"

#include "py/runtime.h"
#include "py/mpprint.h"

// Callback to populate the model input data byte array (laid out in [height][width][channel] order).
typedef void (*libtf_interpreter_input_data_callback_t)(TfLiteTensor *input_tensor); // Actual is float32 (not optimal - network should be fixed). Input should be ([0:255]->[0.0f:+1.0f]).

// Callback to use the model output data byte array (laid out in [height][width][channel] order).
typedef void (*libtf_interpreter_output_data_callback_t)(TfLiteTensor *output_tensor); // Actual is float32 (not optimal - network should be fixed). Output is [0.0f:+1.0f].

int libtf_interpreter_init(microlite_interpreter_obj_t *microlite_interpreter);

TfLiteTensor *libtf_interpreter_get_input_tensor(microlite_interpreter_obj_t *microlite_interpreter, mp_uint_t index);

TfLiteTensor *libtf_interpreter_get_output_tensor(microlite_interpreter_obj_t *microlite_interpreter, mp_uint_t index);

// get the input tensor
mp_obj_t libtf_interpreter_get_input(microlite_interpreter_obj_t *microlite_interpreter, int index);

int libtf_interpreter_outputs(microlite_interpreter_obj_t *microlite_interpreter);

// Returns 0 on success and 1 on failure.
// Errors are printed to stdout.
int libtf_interpreter_invoke(microlite_interpreter_obj_t *interpreter); // Callback to use the model output data byte array.

#ifdef __cplusplus
}
#endif

#endif // __OPENMV_LIBTF_H
