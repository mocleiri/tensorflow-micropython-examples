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

#include "py/runtime.h"
#include "py/obj.h"
#include "py/objstr.h"
#include "py/objarray.h"

/*
 The BuiltinOperator enum from schema_generated.h which 
 is c++ only.

 The values here match the functions specified in 
 MicroMutableOpResolver.
 */
enum  {
  MicroliteOperator_ABS = 0,
  MicroliteOperator_ADD = 1,
  MicroliteOperator_ADD_N = 2,
  MicroliteOperator_ARG_MAX = 3,
  MicroliteOperator_ARG_MIN = 4,
  MicroliteOperator_AVERAGE_POOL_2D = 5,
  MicroliteOperator_BATCH_TO_SPACE_ND = 6,
  MicroliteOperator_CAST = 7,
  MicroliteOperator_CEIL = 8,
  MicroliteOperator_CIRCULAR_BUFFER = 9,
  MicroliteOperator_CONCATENATION = 10,
    MicroliteOperator_CONV_2D = 11,
    MicroliteOperator_COS = 12,
    MicroliteOperator_CUMSUM   = 13,
    MicroliteOperator_DEPTH_TO_SPACE = 14,  
    MicroliteOperator_DEPTHWISE_CONV_2D   = 15,
    MicroliteOperator_DEQUANTIZE   = 16,
    MicroliteOperator_DETECTION_POSTPROCESS   = 17,
    MicroliteOperator_ELU   = 18,
    MicroliteOperator_EQUAL   = 19,
    MicroliteOperator_ETHOSU   = 20,
    MicroliteOperator_EXP   = 21,
    MicroliteOperator_EXPAND_DIMS = 22,  
    MicroliteOperator_FILL   = 23,
    MicroliteOperator_FLOOR   = 24,
    MicroliteOperator_FLOOR_DIV   = 25,
    MicroliteOperator_FLOOR_MOD   = 26,
    MicroliteOperator_FULLY_CONNECTED   = 27,
    MicroliteOperator_GATHER   = 28,
    MicroliteOperator_GATHER_ND   = 29,
    MicroliteOperator_GREATER   = 30,
    MicroliteOperator_GREATER_EQUAL   = 31,
    MicroliteOperator_HARD_SWISH   = 32,
    MicroliteOperator_IF   = 33,
    MicroliteOperator_L2_NORMALIZATION   = 34,
    MicroliteOperator_L2_POOL_2D   = 35,
    MicroliteOperator_LEAKY_RELU   = 36,
    MicroliteOperator_LESS   = 37,
    MicroliteOperator_LESS_EQUAL   = 38,
    MicroliteOperator_LOG   = 39,
    MicroliteOperator_LOGICAL_AND = 40,  
    MicroliteOperator_LOGICAL_NOT   = 41,
    MicroliteOperator_LOGICAL_OR   = 42,
    MicroliteOperator_LOGISTIC   = 43,
    MicroliteOperator_MAXIMUM   = 44, 
    MicroliteOperator_MAX_POOL_2D   = 45,
    MicroliteOperator_MEAN   = 46,
    MicroliteOperator_MINIMUM   = 47,
    MicroliteOperator_MUL   = 48,
    MicroliteOperator_NEG   = 49,
    MicroliteOperator_NOT_EQUAL   = 50,
    MicroliteOperator_PACK   = 51,
    MicroliteOperator_PAD   = 52,
    MicroliteOperator_PADV2   = 53,
    MicroliteOperator_PRELU   = 54,
    MicroliteOperator_QUANTIZE   = 55,
    MicroliteOperator_REDUCE_MAX   = 56,
    MicroliteOperator_RELU   = 57,
    MicroliteOperator_RELU6   = 58,
    MicroliteOperator_RESHAPE   = 59,
    MicroliteOperator_RESIZE_BILINEAR   = 60,
    MicroliteOperator_RESIZE_NEAREST_NEIGHBOR   = 61,
    MicroliteOperator_ROUND   = 62,
    MicroliteOperator_RSQRT   = 63,
    MicroliteOperator_SHAPE   = 64,
    MicroliteOperator_SIN   = 65,
    MicroliteOperator_SOFTMAX   = 66,
    MicroliteOperator_SPACE_TO_BATCH_ND   = 67,
    MicroliteOperator_SPACE_TO_DEPTH   = 68, 
    MicroliteOperator_SPLIT   = 69,
    MicroliteOperator_SPLIT_V   = 70,
    MicroliteOperator_SQUEEZE   = 71, 
    MicroliteOperator_SQRT   = 72,
    MicroliteOperator_SQUARE   = 73,
    MicroliteOperator_STRIDED_SLICE  = 74, 
    MicroliteOperator_SUB   = 75,
    MicroliteOperator_SVDF   = 76,
    MicroliteOperator_TANH   = 77,
    MicroliteOperator_TRANSPOSE_CONV   = 78,
    MicroliteOperator_TRANSPOSE   = 79,
    MicroliteOperator_UNPACK   = 80,
    MicroliteOperator_ZEROS_LIKE   = 81,

} microlite_op_t;

enum {
    ALL_OPS = 0,
    SPECIFIED_OPS = 1
} microlite_op_mode_t;

typedef struct _microlite_op_resolver_obj_t {
    mp_obj_base_t base;   
    microlite_op_mode_t mode; 
    mp_int_t number_of_ops;
    mp_obj_t tf_op_resolver;
} microlite_op_resolver_obj_t;

typedef struct _microlite_model_obj_t {
    mp_obj_base_t base;
    mp_obj_array_t  *model_data;
    mp_obj_t tf_model;
} microlite_model_obj_t;


typedef struct _microlite_interpreter_obj_t {
    mp_obj_base_t base;
    mp_obj_array_t  *model_data;
    mp_obj_array_t  *tensor_area;
    microlite_op_resolver_obj_t *op_resolver;
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

#ifdef __cplusplus
}
#endif

#endif

