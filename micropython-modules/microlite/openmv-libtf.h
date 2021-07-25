/* This file is part of the OpenMV project.
 * Copyright (c) 2013-2019 Ibrahim Abdelkader <iabdalkader@openmv.io> & Kwabena W. Agyeman <kwagyeman@openmv.io>
 * This work is licensed under the MIT license, see the file LICENSE for details.
 */

#ifndef __OPENMV_LIBTF_H
#define __OPENMV_LIBTF_H

#ifdef __cplusplus
extern "C" {
#endif


#include "tensorflow/lite/c/common.h"

#include "py/runtime.h"
#include "py/mpprint.h"

// Call this first to get the shape of the model input.
// Returns 0 on success and 1 on failure.
// Errors are printed to stdout.
//int libtf_get_input_data_hwc(const unsigned char *model_data, // TensorFlow Lite binary model (8-bit quant).
//                             unsigned char *tensor_arena, // As big as you can make it scratch buffer.
//                             unsigned int tensor_arena_size, // Size of the above scratch buffer.
//                             unsigned int *input_height, // Height for the model.
//                             unsigned int *input_width, // Width for the model.
//                             unsigned int *input_channels, // Channels for the model (1 for grayscale8 and 3 for rgb888).
//                             bool *signed_or_unsigned, // True if input is int8_t ([0:255]->[-128:127]), False if input is uint8_t ([0:255]->[0:255]).
//                             bool *is_float); // Actual is float32 (not optimal - network should be fixed). Input should be ([0:255]->[0.0f:+1.0f]).

// Call this second to get the shape of the model output.
// Returns 0 on success and 1 on failure.
// Errors are printed to stdout.
//int libtf_get_output_data_hwc(const unsigned char *model_data, // TensorFlow Lite binary model (8-bit quant).
//                              unsigned char *tensor_arena, // As big as you can make it scratch buffer.
//                              unsigned int tensor_arena_size, // Size of the above scratch buffer.
//                              unsigned int *output_height, // Height for the model.
//                              unsigned int *output_width, // Width for the model.
//                              unsigned int *output_channels, // Channels for the model (1 for grayscale8 and 3 for rgb888).
//                              bool *signed_or_unsigned, // True if output is int8_t ([-128:127]->[0:255]->[0.0f:1.0f]), False if output is uint8_t ([0:255]->[0:255]->[0.0f:1.0f]).
//                              bool *is_float); // Actual is float32 (not optimal - network should be fixed). Output is [0.0f:+1.0f].

// Callback to populate the model input data byte array (laid out in [height][width][channel] order).
typedef void (*libtf_input_data_callback_t)(TfLiteTensor *input_tensor); // Actual is float32 (not optimal - network should be fixed). Input should be ([0:255]->[0.0f:+1.0f]).

// Callback to use the model output data byte array (laid out in [height][width][channel] order).
typedef void (*libtf_output_data_callback_t)(TfLiteTensor *output_tensor); // Actual is float32 (not optimal - network should be fixed). Output is [0.0f:+1.0f].

// used to call the op_resolver.add{op_name} to register the op.
int libtf_op_resolver_add(mp_obj_t tf_op_resolver, mp_obj_str_t *op_name);

// used to initialize the tflite::OpResolver
// it can either be all operations or use the mutable op where we register it.
int libtf_init_op_resolver(microlite_op_resolver_obj_t *microlite_op_resolver);

// used to initialize the tflite::interpreter in C++
// and to put the pointers into the microlite_interpreter object
int libtf_init_interpreter(microlite_interpreter_obj_t *microlite_interpretor);

TfLiteTensor *libtf_get_input_tensor(microlite_interpreter_obj_t *microlite_interpretor, mp_uint_t index);

TfLiteTensor *libtf_get_output_tensor(microlite_interpreter_obj_t *microlite_interpretor, mp_uint_t index);

// get the input tensor
mp_obj_t libtf_get_input(microlite_interpreter_obj_t *microlite_interpretor, int index);

int libtf_interpreter_outputs(microlite_interpreter_obj_t *microlite_interpretor);

// Returns 0 on success and 1 on failure.
// Errors are printed to stdout.
int libtf_invoke(microlite_interpreter_obj_t *interpreter); // Callback to use the model output data byte array.

// Returns 0 on success and 1 on failure.
// Errors are printed to stdout.
int libtf_initialize_micro_features();

// Returns 0 on success and 1 on failure.
// Errors are printed to stdout.
// Converts audio sample data into a more compact form that's
// appropriate for feeding into a neural network.
int libtf_generate_micro_features(const int16_t* input, // Audio samples
                                  int input_size, // Audio samples size
                                  int output_size, // Slice size
                                  int8_t* output, // Slice data
                                  size_t* num_samples_read); // Number of samples used.

#ifdef __cplusplus
}
#endif

#endif // __OPENMV_LIBTF_H
