/*
 * This file is part of the Tensorflow Micropython Examples Project.
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2021 Michael O'Cleirigh
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
#ifndef HELLO_WORLD_MICRO_LITE_H_
#define HELLO_WORLD_MICRO_LITE_H_



#ifdef __cplusplus
extern "C" {
#endif

#include <string.h>

#include "py/runtime.h"
#include "py/obj.h"
#include "py/objstr.h"
#include "py/objarray.h"

#include "tensorflow/lite/experimental/microfrontend/lib/frontend.h"
#include "tensorflow/lite/experimental/microfrontend/lib/frontend_util.h"

// TODO #15 get this from the tensorflow submodule via a ci script
#define TFLITE_MICRO_VERSION "e87305ee53c124188d0390b1ef8ec0555760d4d6"

typedef struct _microlite_model_obj_t {
    mp_obj_base_t base;
    mp_obj_array_t  *model_data;
    mp_obj_t tf_model;
} microlite_model_obj_t;


typedef struct _microlite_interpreter_obj_t {
    mp_obj_base_t base;
    mp_obj_array_t  *model_data;
    mp_obj_array_t  *tensor_area;
    mp_obj_t tf_interpreter;
    mp_obj_t tf_model;
    mp_obj_t tf_error_reporter;
    int16_t inference_count;
    mp_obj_t input_callback;
    mp_obj_t output_callback;
} microlite_interpreter_obj_t;

typedef struct _microlite_tensor_obj_t {
    mp_obj_base_t base;    
    mp_obj_t tf_tensor;
    microlite_interpreter_obj_t *microlite_interpreter;
} microlite_tensor_obj_t;

typedef struct _microlite_audio_frontend_obj_t {
     mp_obj_base_t base; 
     struct FrontendConfig *config;
     struct FrontendState *state;
} microlite_audio_frontend_obj_t;

mp_obj_t audio_frontend_execute (mp_obj_t self_in, mp_obj_t input);
mp_obj_t audio_frontend_configure (mp_obj_t self_in);

#ifdef __cplusplus
}
#endif

#endif

