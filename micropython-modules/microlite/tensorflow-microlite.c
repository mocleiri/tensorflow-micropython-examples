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
// Include MicroPython API.
#include "py/runtime.h"
#include "py/mpprint.h"
#include "py/objstr.h"
#include "py/objarray.h"
#include "py/mpprint.h"
#include "py/qstr.h"
#include "py/misc.h"

#include "tensorflow-microlite.h"

#include "hello-world-model.h"

#include "openmv-libtf.h"

#include "tensorflow/lite/version.h"
#include "tensorflow/lite/c/common.h"

const mp_obj_type_t microlite_model_type;
const mp_obj_type_t microlite_interpreter_type;
const mp_obj_type_t microlite_op_resolver_type;
const mp_obj_type_t microlite_tensor_type;

// - microlite tensor
STATIC void tensor_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    (void)kind;
    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    mp_print_str(print, "tensor(type=");

    mp_print_str(print, TfLiteTypeGetName(tensor->type));

    int size = tensor->dims->size;

    mp_printf(print, ", dims->size=%d\n", size);

    mp_print_str(print, ")\n");
}

STATIC mp_obj_t tensor_get_tensor_type (mp_obj_t self_in, mp_obj_t index_obj) {

    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    char *type = TfLiteTypeGetName(tensor->type);

    return mp_obj_new_str(type, strlen(type));

}

MP_DEFINE_CONST_FUN_OBJ_0(microlite_tensor_get_tensor_type, tensor_get_tensor_type);


STATIC mp_obj_t tensor_get_value (mp_obj_t self_in, mp_obj_t index_obj) {

    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    if (tensor->type == kTfLiteFloat32) {
        mp_int_t index = mp_obj_int_get_checked(index_obj);

        float f_value = tensor->data.f[index];

        return mp_obj_new_float_from_f(f_value);
    }
    else if (tensor->type == kTfLiteInt8) {
        mp_int_t index = mp_obj_int_get_checked(index_obj);

        int8_t int8_value = tensor->data.int8[index];

        return mp_obj_new_int(int8_value);
    }
     else if (tensor->type == kTfLiteUInt8) {
        mp_int_t index = mp_obj_int_get_checked(index_obj);

        uint8_t int8_value = tensor->data.uint8[index];

        return mp_obj_new_int(int8_value);
    }
    else {
        mp_raise_TypeError("Unsupported Tensor Type");
    }

    return mp_const_none;
}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_get_value, tensor_get_value);

STATIC mp_obj_t tensor_set_value (mp_obj_t self_in, mp_obj_t index_obj, mp_obj_t value) {
    
    mp_int_t index = mp_obj_int_get_checked(index_obj);

    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    if (tensor->type == kTfLiteFloat32) {
        tensor->data.f[index] = mp_obj_get_float_to_f(value);
    }
    else if (tensor->type == kTfLiteInt8) {
        mp_int_t int_value = mp_obj_int_get_checked(value);

        int8_t int8_value = (int8_t)int_value;

        tensor->data.int8[index] = int8_value;
    }
    else if (tensor->type == kTfLiteUInt8) {
        mp_int_t int_value = mp_obj_int_get_checked(value);

        uint8_t uint8_value = (uint8_t)int_value;

        tensor->data.uint8[index] = uint8_value;
    }
    else {
        mp_raise_TypeError("Unsupported Tensor Type");
    }

    return MP_OBJ_FROM_PTR(self);
}

MP_DEFINE_CONST_FUN_OBJ_3(microlite_tensor_set_value, tensor_set_value);

STATIC mp_obj_t tensor_quantize_float_to_int8 (mp_obj_t self_in, mp_obj_t float_obj) {
    
    if (!mp_obj_is_float(float_obj)) {
         mp_raise_TypeError("Expecting Parameter of float type");
        // return mp_const_none;
    }

    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    if (tensor->type != kTfLiteInt8) {
        mp_raise_TypeError ("Expected Tensor to be of type ktfLiteInt8.");
    }

    // may need to add #ifdef sheild on this method as its only defined on boards with floating point
    float value = mp_obj_get_float_to_f(float_obj);

    // Quantize the input from floating-point to integer
    int8_t quantized_value = (int8_t)(value / tensor->params.scale + tensor->params.zero_point);

    return MP_OBJ_NEW_SMALL_INT(quantized_value);
}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_quantize_float_to_int8, tensor_quantize_float_to_int8);

STATIC mp_obj_t tensor_quantize_int8_to_float (mp_obj_t self_in, mp_obj_t int_obj) {
    
    if (!mp_obj_is_integer(int_obj)) {
         mp_raise_TypeError("Expecting Parameter of float type");
        // return mp_const_none;
    }

    microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    if (tensor->type != kTfLiteInt8) {
        mp_raise_TypeError ("Expected Tensor to be of type ktfLiteInt8.");
    }

    // may need to add #ifdef sheild on this method as its only defined on boards with floating point
    int8_t value = mp_obj_int_get_checked(int_obj);

    // Quantize the input from floating-point to integer
    float quantized_value = (value - tensor->params.zero_point) * tensor->params.scale;

    return mp_obj_new_float_from_f(quantized_value);
}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_quantize_int8_to_float, tensor_quantize_int8_to_float);

// interpreter class
STATIC const mp_rom_map_elem_t tensor_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_getValue), MP_ROM_PTR(&microlite_tensor_get_value) },
    { MP_ROM_QSTR(MP_QSTR_setValue), MP_ROM_PTR(&microlite_tensor_set_value) },
    { MP_ROM_QSTR(MP_QSTR_getType), MP_ROM_PTR(&microlite_tensor_get_tensor_type) },
    { MP_ROM_QSTR(MP_QSTR_quantizeFloatToInt8), MP_ROM_PTR(&microlite_tensor_quantize_float_to_int8) },
    { MP_ROM_QSTR(MP_QSTR_quantizeInt8ToFloat), MP_ROM_PTR(&microlite_tensor_quantize_int8_to_float) }
};

STATIC MP_DEFINE_CONST_DICT(tensor_locals_dict, tensor_locals_dict_table);

const mp_obj_type_t microlite_tensor_type = {
    { &mp_type_type },
    .name = MP_QSTR_tensor,
    .print = tensor_print,
    .locals_dict = (mp_obj_dict_t*)&tensor_locals_dict,
};


// - microlite interpreter

STATIC void interpreter_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    (void)kind;
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);
    mp_print_str(print, "interpreter(");
//    mp_obj_print_helper(print, mp_obj_new_int(self->a), PRINT_REPR);
//    mp_print_str(print, ", ");
//    mp_obj_print_helper(print, mp_obj_new_int(self->b), PRINT_REPR);
    mp_print_str(print, ")");
}

STATIC mp_obj_t interpreter_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    mp_arg_check_num(n_args, n_kw, 5, 5, false);

//    args:
//      - model
//      - op_resolver
//      - size of the tensor area
//      - input callback function
//      - output callback function

    mp_obj_array_t *model = MP_OBJ_TO_PTR (args[0]);

    microlite_op_resolver_obj_t *op_resolver = MP_OBJ_TO_PTR (args[1]);

    int tensor_area_len = mp_obj_get_int(args[2]);

    mp_obj_t input_callback_fn = args[3];

    mp_obj_t output_callback_fn = args[4];

    if (input_callback_fn != mp_const_none && !mp_obj_is_callable(input_callback_fn)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Invalid Input Callback Handler"));
    }

    if (output_callback_fn != mp_const_none && !mp_obj_is_callable(output_callback_fn)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Invalid Output Callback Handler"));
    }

    // to start with just hard code to the hello-world model

    microlite_interpreter_obj_t *self = m_new_obj(microlite_interpreter_obj_t);

    self->base.type = &microlite_interpreter_type;

    self->input_callback = input_callback_fn;
    self->output_callback = output_callback_fn;

    self->inference_count = 0;

    self->op_resolver = op_resolver;

    self->model_data = model;

    byte *tensor_area_buffer = m_new(byte, tensor_area_len);

    self->tensor_area = mp_obj_new_bytearray_by_ref (tensor_area_len, tensor_area_buffer);

    mp_printf(MP_PYTHON_PRINTER, "interpreter_make_new: model size = %d, tensor area = %d\n", self->model_data->len, tensor_area_len);

    libtf_init(self);

    return MP_OBJ_FROM_PTR(self);
}

// called before passing the tensor to the callback
STATIC mp_obj_t interpreter_get_input_tensor(mp_obj_t self_in, mp_obj_t index_obj) {

    mp_uint_t index = mp_obj_int_get_uint_checked(index_obj);

    microlite_interpreter_obj_t *microlite_interpreter = MP_OBJ_TO_PTR(self_in);

    microlite_tensor_obj_t *microlite_tensor = m_new_obj(microlite_tensor_obj_t);

    TfLiteTensor *input_tensor = libtf_get_input_tensor(microlite_interpreter, index);

    microlite_tensor->tf_tensor = input_tensor;
    microlite_tensor->microlite_interpreter = microlite_interpreter;
    microlite_tensor->base.type = &microlite_tensor_type;

    return MP_OBJ_FROM_PTR(microlite_tensor);
}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_interpreter_get_input_tensor, interpreter_get_input_tensor);

STATIC mp_obj_t interpreter_get_output_tensor(mp_obj_t self_in, mp_obj_t index_obj) {

    mp_uint_t index = mp_obj_int_get_uint_checked(index_obj);

    microlite_interpreter_obj_t *microlite_interpreter = MP_OBJ_TO_PTR(self_in);

    microlite_tensor_obj_t *microlite_tensor = m_new_obj(microlite_tensor_obj_t);

    TfLiteTensor *output_tensor = libtf_get_output_tensor(microlite_interpreter, index);

    microlite_tensor->tf_tensor = output_tensor;
    microlite_tensor->microlite_interpreter = microlite_interpreter;
    microlite_tensor->base.type = &microlite_tensor_type;

    return MP_OBJ_FROM_PTR(microlite_tensor);
}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_interpreter_get_output_tensor, interpreter_get_output_tensor);

STATIC mp_obj_t interpreter_invoke(mp_obj_t self_in) {
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);

    
    int code = libtf_invoke(self);

    self->inference_count += 1;

    return mp_obj_new_int(code);

}

MP_DEFINE_CONST_FUN_OBJ_1(microlite_interpreter_invoke, interpreter_invoke);



// interpreter class
STATIC const mp_rom_map_elem_t interpreter_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_invoke), MP_ROM_PTR(&microlite_interpreter_invoke) },
    { MP_ROM_QSTR(MP_QSTR_getInputTensor), MP_ROM_PTR(&microlite_interpreter_get_input_tensor) },
    { MP_ROM_QSTR(MP_QSTR_getOutputTensor), MP_ROM_PTR(&microlite_interpreter_get_output_tensor) },
};

STATIC MP_DEFINE_CONST_DICT(interpreter_locals_dict, interpreter_locals_dict_table);

const mp_obj_type_t microlite_interpreter_type = {
    { &mp_type_type },
    .name = MP_QSTR_interpreter,
    .print = interpreter_print,
    .make_new = interpreter_make_new,
    .locals_dict = (mp_obj_dict_t*)&interpreter_locals_dict,
};

STATIC void op_resolver_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    (void)kind;
    microlite_op_resolver_obj_t *self = MP_OBJ_TO_PTR(self_in);

    if (self.mode == ALL_OPS) {
        mp_print_str(print, "AllOpResolver(All tensorflow micro ops are loaded and available)");
    }
    else if (self.mode == SPECIFIED_OPS) {
        mp_print_str(print, "MutableOpResolver(Only specified ops are loaded)");
    }
    else {
        mp_raise_ValueError("Unknown mode: ", self.mode);
    }
}

STATIC mp_obj_t op_resolver_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    enum {
        ARG_mode,
        ARG_size // if mode is SPECIFIED_OPS then this is how many ops we will expect
    };

    static const mp_arg_t allowed_args[] = {
        { MP_QSTR_mode,     MP_ARG_KW_ONLY | MP_ARG_REQUIRED | MP_ARG_INT,   {.u_int = -1} },
        { MP_QSTR_size,     MP_ARG_KW_ONLY | MP_ARG_INT,   {.u_int = -1} }
    };

    mp_arg_val_t args[MP_ARRAY_SIZE(allowed_args)];
    mp_arg_parse_all(n_args, pos_args, kw_args, MP_ARRAY_SIZE(allowed_args), allowed_args, args);

    microlite_op_resolver_obj_t *op_resolver = m_new_obj(microlite_op_resolver_obj_t);

    op_resolver->mode = args[ARG_mode].u_int;

    //
    // ---- Check validity of arguments ----
    //

    // is Mode valid?
    if ((op_resolver->mode != (ALL_OPS) &&
        (op_resolver->mode != (SPECIFIED_OPS))) {
        mp_raise_ValueError(MP_ERROR_TEXT("invalid mode"));
    }

    // is Bits valid?
    if (op_resolver->mode == SPECIFIED_OPS) {
        op_resolver->number_of_ops = args[ARG_size].u_int;

    }
    else {
        // all ops mode
        op_resolver->number_of_ops = 128; 

    }
    
    
    self->base.type = &microlite_op_resolver_type;

    libtf_init_op_resolver(self);

    return MP_OBJ_FROM_PTR(self);
}

STATIC int op_resolver_add(mp_obj_t self_in, mp_int_t op) {

    microlite_op_resolver_obj_t *self = MP_OBJ_TO_PTR(self_in);

    return libtf_op_resolver_add(self, op);

}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_op_resolver_add, op_resolver_add);

// interpreter class
STATIC const mp_rom_map_elem_t op_resolver_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_addOp), MP_ROM_PTR(&microlite_op_resolver_add) },

    // Constants
    { MP_ROM_QSTR(MP_QSTR_ALL_OPS),         MP_ROM_INT(ALL_OPS) },
    { MP_ROM_QSTR(MP_QSTR_SPECIFIED_OPS),   MP_ROM_INT(SPECIFIED_OPS) },
    { MP_ROM_QSTR(MP_QSTR_ABS),            MP_ROM_INT(MicroliteOperator_ABS) },
    { MP_ROM_QSTR(MP_QSTR_ADD),            MP_ROM_INT(MicroliteOperator_ADD) },
      { MP_ROM_QSTR(MP_QSTR_ADD_N),            MP_ROM_INT(MicroliteOperator_ADD_N) },
      { MP_ROM_QSTR(MP_QSTR_MAX),            MP_ROM_INT(MicroliteOperator_ARG_MAX) },
      { MP_ROM_QSTR(MP_QSTR_MIN),            MP_ROM_INT(MicroliteOperator_ARG_MIN) },
      { MP_ROM_QSTR(MP_QSTR_AVERAGE_POOL_2D),            MP_ROM_INT(MicroliteOperator_AVERAGE_POOL_2D) },
      { MP_ROM_QSTR(MP_QSTR_BATCH_TO_SPACE_ND),            MP_ROM_INT(MicroliteOperator_BATCH_TO_SPACE_ND) },
      { MP_ROM_QSTR(MP_QSTR_CAST),            MP_ROM_INT(MicroliteOperator_CAST) },
      { MP_ROM_QSTR(MP_QSTR_CEIL),            MP_ROM_INT(MicroliteOperator_CEIL) },
      { MP_ROM_QSTR(MP_QSTR_CIRCULAR_BUFFER),            MP_ROM_INT(MicroliteOperator_CIRCULAR_BUFFER) },
      { MP_ROM_QSTR(MP_QSTR_CONCATENATION),            MP_ROM_INT(MicroliteOperator_CONCATENATION) },
        { MP_ROM_QSTR(MP_QSTR_CONV_2D),            MP_ROM_INT(MicroliteOperator_CONV_2D) },
        { MP_ROM_QSTR(MP_QSTR_COS),            MP_ROM_INT(MicroliteOperator_COS) },
        { MP_ROM_QSTR(MP_QSTR_CUMSUM),            MP_ROM_INT(MicroliteOperator_CUMSUM) },
        { MP_ROM_QSTR(MP_QSTR_DEPTH_TO_SPACE),            MP_ROM_INT(MicroliteOperator_DEPTH_TO_SPACE) },
        { MP_ROM_QSTR(MP_QSTR_DEPTHWISE_CONV_2D),            MP_ROM_INT(MicroliteOperator_DEPTHWISE_CONV_2D) },
        { MP_ROM_QSTR(MP_QSTR_DEQUANTIZE),            MP_ROM_INT(MicroliteOperator_DEQUANTIZE) },
        { MP_ROM_QSTR(MP_QSTR_DETECTION_POSTPROCESS),            MP_ROM_INT(MicroliteOperator_DETECTION_POSTPROCESS) },
        { MP_ROM_QSTR(MP_QSTR_ELU),            MP_ROM_INT(MicroliteOperator_ELU) },
        { MP_ROM_QSTR(MP_QSTR_EQUAL),            MP_ROM_INT(MicroliteOperator_EQUAL) },
        { MP_ROM_QSTR(MP_QSTR_ETHOSU),            MP_ROM_INT(MicroliteOperator_ETHOSU) },
        { MP_ROM_QSTR(MP_QSTR_EXP),            MP_ROM_INT(MicroliteOperator_EXP) },
        { MP_ROM_QSTR(MP_QSTR_EXPAND_DIMS),            MP_ROM_INT(MicroliteOperator_EXPAND_DIMS) },
        { MP_ROM_QSTR(MP_QSTR_FILL),            MP_ROM_INT(MicroliteOperator_FILL) },
        { MP_ROM_QSTR(MP_QSTR_FLOOR),            MP_ROM_INT(MicroliteOperator_FLOOR) },
        { MP_ROM_QSTR(MP_QSTR_FLOOR_DIV),            MP_ROM_INT(MicroliteOperator_FLOOR_DIV) },
        { MP_ROM_QSTR(MP_QSTR_FLOOR_MOD),            MP_ROM_INT(MicroliteOperator_FLOOR_MOD) },
        { MP_ROM_QSTR(MP_QSTR_FULLY_CONNECTED),            MP_ROM_INT(MicroliteOperator_FULLY_CONNECTED) },
        { MP_ROM_QSTR(MP_QSTR_GATHER),            MP_ROM_INT(MicroliteOperator_GATHER) },
        { MP_ROM_QSTR(MP_QSTR_GATHER_ND),            MP_ROM_INT(MicroliteOperator_GATHER_ND) },
        { MP_ROM_QSTR(MP_QSTR_GREATER),            MP_ROM_INT(MicroliteOperator_GREATER) },
        { MP_ROM_QSTR(MP_QSTR_GREATER_EQUAL),            MP_ROM_INT(MicroliteOperator_GREATER_EQUAL) },
        { MP_ROM_QSTR(MP_QSTR_HARD_SWISH),            MP_ROM_INT(MicroliteOperator_HARD_SWISH) },
        { MP_ROM_QSTR(MP_QSTR_IF),            MP_ROM_INT(MicroliteOperator_IF) },
        { MP_ROM_QSTR(MP_QSTR_L2_NORMALIZATION),            MP_ROM_INT(MicroliteOperator_L2_NORMALIZATION) },
        { MP_ROM_QSTR(MP_QSTR_L2_POOL_2D),            MP_ROM_INT(MicroliteOperator_L2_POOL_2D) },
        { MP_ROM_QSTR(MP_QSTR_LEAKY_RELU),            MP_ROM_INT(MicroliteOperator_LEAKY_RELU) },
        { MP_ROM_QSTR(MP_QSTR_LESS),            MP_ROM_INT(MicroliteOperator_LESS) },
        { MP_ROM_QSTR(MP_QSTR_LESS_EQUAL),            MP_ROM_INT(MicroliteOperator_LESS_EQUAL) },
        { MP_ROM_QSTR(MP_QSTR_LOG),            MP_ROM_INT(MicroliteOperator_LOG) },
        { MP_ROM_QSTR(MP_QSTR_LOGICAL_AND),            MP_ROM_INT(MicroliteOperator_LOGICAL_AND) },
        { MP_ROM_QSTR(MP_QSTR_LOGICAL_NOT),            MP_ROM_INT(MicroliteOperator_LOGICAL_NOT) },
        { MP_ROM_QSTR(MP_QSTR_LOGICAL_OR),            MP_ROM_INT(MicroliteOperator_LOGICAL_OR) },
        { MP_ROM_QSTR(MP_QSTR_LOGISTIC),            MP_ROM_INT(MicroliteOperator_LOGISTIC) },
        { MP_ROM_QSTR(MP_QSTR_MAXIMUM),            MP_ROM_INT(MicroliteOperator_MAXIMUM) },
        { MP_ROM_QSTR(MP_QSTR_MAX_POOL_2D),            MP_ROM_INT(MicroliteOperator_MAX_POOL_2D) },
        { MP_ROM_QSTR(MP_QSTR_MEAN),            MP_ROM_INT(MicroliteOperator_MEAN) },
        { MP_ROM_QSTR(MP_QSTR_MINIMUM),            MP_ROM_INT(MicroliteOperator_MINIMUM) },
        { MP_ROM_QSTR(MP_QSTR_MUL),            MP_ROM_INT(MicroliteOperator_MUL) },
        { MP_ROM_QSTR(MP_QSTR_NEG),            MP_ROM_INT(MicroliteOperator_NEG) },
        { MP_ROM_QSTR(MP_QSTR_NOT_EQUAL),            MP_ROM_INT(MicroliteOperator_NOT_EQUAL) },
        { MP_ROM_QSTR(MP_QSTR_PACK),            MP_ROM_INT(MicroliteOperator_PACK) },
        { MP_ROM_QSTR(MP_QSTR_PAD),            MP_ROM_INT(MicroliteOperator_PAD) },
        { MP_ROM_QSTR(MP_QSTR_PADV2),            MP_ROM_INT(MicroliteOperator_PADV2) },
        { MP_ROM_QSTR(MP_QSTR_PRELU),            MP_ROM_INT(MicroliteOperator_PRELU) },
        { MP_ROM_QSTR(MP_QSTR_QUANTIZE),            MP_ROM_INT(MicroliteOperator_QUANTIZE) },
        { MP_ROM_QSTR(MP_QSTR_REDUCE_MAX),            MP_ROM_INT(MicroliteOperator_REDUCE_MAX) },
        { MP_ROM_QSTR(MP_QSTR_RELU),            MP_ROM_INT(MicroliteOperator_RELU) },
        { MP_ROM_QSTR(MP_QSTR_RELU6),            MP_ROM_INT(MicroliteOperator_RELU6) },
        { MP_ROM_QSTR(MP_QSTR_RESHAPE),            MP_ROM_INT(MicroliteOperator_RESHAPE) },
        { MP_ROM_QSTR(MP_QSTR_RESIZE_BILINEAR),            MP_ROM_INT(MicroliteOperator_RESIZE_BILINEAR) },
        { MP_ROM_QSTR(MP_QSTR_RESIZE_NEAREST_NEIGHBOR),            MP_ROM_INT(MicroliteOperator_RESIZE_NEAREST_NEIGHBOR) },
        { MP_ROM_QSTR(MP_QSTR_ROUND),            MP_ROM_INT(MicroliteOperator_ROUND) },
        { MP_ROM_QSTR(MP_QSTR_RSQRT),            MP_ROM_INT(MicroliteOperator_RSQRT) },
        { MP_ROM_QSTR(MP_QSTR_SHAPE),            MP_ROM_INT(MicroliteOperator_SHAPE) },
        { MP_ROM_QSTR(MP_QSTR_SIN),            MP_ROM_INT(MicroliteOperator_SIN) },
        { MP_ROM_QSTR(MP_QSTR_SOFTMAX),            MP_ROM_INT(MicroliteOperator_SOFTMAX) },
        { MP_ROM_QSTR(MP_QSTR_SPACE_TO_BATCH_ND),            MP_ROM_INT(MicroliteOperator_SPACE_TO_BATCH_ND) },
        { MP_ROM_QSTR(MP_QSTR_SPACE_TO_DEPTH),            MP_ROM_INT(MicroliteOperator_SPACE_TO_DEPTH) },
        { MP_ROM_QSTR(MP_QSTR_SPLIT),            MP_ROM_INT(MicroliteOperator_SPLIT) },
        { MP_ROM_QSTR(MP_QSTR_SPLIT_V),            MP_ROM_INT(MicroliteOperator_SPLIT_V) },
        { MP_ROM_QSTR(MP_QSTR_SQUEEZE),            MP_ROM_INT(MicroliteOperator_SQUEEZE) },
        { MP_ROM_QSTR(MP_QSTR_SQRT),            MP_ROM_INT(MicroliteOperator_SQRT) },
        { MP_ROM_QSTR(MP_QSTR_SQUARE),            MP_ROM_INT(MicroliteOperator_SQUARE) },
        { MP_ROM_QSTR(MP_QSTR_STRIDED_SLICE),            MP_ROM_INT(MicroliteOperator_STRIDED_SLICE) },
        { MP_ROM_QSTR(MP_QSTR_SUB),            MP_ROM_INT(MicroliteOperator_SUB) },
        { MP_ROM_QSTR(MP_QSTR_SVDF),            MP_ROM_INT(MicroliteOperator_SVDF) },
        { MP_ROM_QSTR(MP_QSTR_TANH),            MP_ROM_INT(MicroliteOperator_TANH) },
        { MP_ROM_QSTR(MP_QSTR_TRANSPOSE_CONV),            MP_ROM_INT(MicroliteOperator_TRANSPOSE_CONV) },
        { MP_ROM_QSTR(MP_QSTR_TRANSPOSE),            MP_ROM_INT(MicroliteOperator_TRANSPOSE) },
        { MP_ROM_QSTR(MP_QSTR_UNPACK),            MP_ROM_INT(MicroliteOperator_UNPACK) },
        { MP_ROM_QSTR(MP_QSTR_ZEROS_LIKE),            MP_ROM_INT(MicroliteOperator_ZEROS_LIKE) },

};

STATIC MP_DEFINE_CONST_DICT(op_resolver_locals_dict, op_resolver_locals_dict_table);

const mp_obj_type_t microlite_op_resolver_type = {
    { &mp_type_type },
    .name = MP_QSTR_OpResolver,
    .print = op_resolver_print,
    .make_new = op_resolver_make_new,
    .locals_dict = (mp_obj_dict_t*)&op_resolver_locals_dict,
};


// model class
STATIC void model_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    (void)kind;
    microlite_model_obj_t *self = MP_OBJ_TO_PTR(self_in);
    mp_print_str(print, "model(size=");

    mp_print_str(print, mp_obj_new_int(self->model_data->len));

    mp_print_str(print, ")");
}

STATIC mp_obj_t model_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    mp_arg_check_num(n_args, n_kw, 5, 5, false);

//    args:
//      - model
//      - op_resolver
//      - size of the tensor area
//      - input callback function
//      - output callback function

    
    // mp_obj_array_t model = MP_OBJ_FROM_PTR (args[0]);

    int tensor_area_len = mp_obj_get_int(args[1]);

    mp_obj_t input_callback_fn = args[2];

    mp_obj_t output_callback_fn = args[3];

    if (input_callback_fn != mp_const_none && !mp_obj_is_callable(input_callback_fn)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Invalid Input Callback Handler"));
    }

    if (output_callback_fn != mp_const_none && !mp_obj_is_callable(output_callback_fn)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Invalid Output Callback Handler"));
    }

    // to start with just hard code to the hello-world model

    microlite_interpreter_obj_t *self = m_new_obj(microlite_interpreter_obj_t);

    self->input_callback = input_callback_fn;
    self->output_callback = output_callback_fn;

    self->op_resolver = op_resolver;
    self->inference_count = 0;

    self->base.type = &microlite_interpreter_type;



    // for now hard code the model to the hello world model
    // self->model_data = mp_obj_new_bytearray_by_ref(g_model_len, g_model);
    // self->model_data = model;

    byte *tensor_area_buffer = m_new(byte, tensor_area_len);

    self->tensor_area = mp_obj_new_bytearray_by_ref (tensor_area_len, tensor_area_buffer);

    mp_printf(MP_PYTHON_PRINTER, "interpreter_make_new: model size = %d, tensor area = %d\n", g_model_len, tensor_area_len);

    libtf_init(self);

    return MP_OBJ_FROM_PTR(self);
}
// STATIC const mp_rom_map_elem_t model_locals_dict_table[] = {
//     { MP_ROM_QSTR(MP_QSTR_invoke), MP_ROM_PTR(&microlite_interpreter_invoke) },
//     { MP_ROM_QSTR(MP_QSTR_getInputTensor), MP_ROM_PTR(&microlite_interpreter_get_input_tensor) },
//     { MP_ROM_QSTR(MP_QSTR_getOutputTensor), MP_ROM_PTR(&microlite_interpreter_get_output_tensor) },
// };

// STATIC MP_DEFINE_CONST_DICT(interpreter_locals_dict, interpreter_locals_dict_table);

const mp_obj_type_t microlite_model_type = {
    { &mp_type_type },
    .name = MP_QSTR_model,
    .print = model_print,
    .make_new = model_make_new,
    .locals_dict = (mp_obj_dict_t*)&interpreter_locals_dict,
};


// main microlite module

// needs to be manually updated when the firmware is built.
// see if we can pass through the project git commit when this is run.
STATIC const MP_DEFINE_STR_OBJ(microlite_version_string_obj, TFLITE_VERSION_STRING);

// Define all properties of the module.
// Table entries are key/value pairs of the attribute name (a string)
// and the MicroPython object reference.
// All identifiers and strings are written as MP_QSTR_xxx and will be
// optimized to word-sized integers by the build system (interned strings).
STATIC const mp_rom_map_elem_t microlite_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_microlite) },
    { MP_ROM_QSTR(MP_QSTR___version__), MP_ROM_PTR(&microlite_version_string_obj) },
    { MP_ROM_QSTR(MP_QSTR_interpreter), (mp_obj_t)&microlite_interpreter_type },
    { MP_ROM_QSTR(MP_QSTR_all_op_resolver), (mp_obj_t)&microlite_all_op_resolver_type },
    { MP_ROM_QSTR(MP_QSTR_mutable_op_resolver), (mp_obj_t)&microlite_mutable_op_resolver_type },
    { MP_ROM_QSTR(MP_QSTR_tensor), (mp_obj_t)&microlite_tensor_type },
    { MP_ROM_QSTR(MP_QSTR_tensor), (mp_obj_t)&microlite_model_type }
};
STATIC MP_DEFINE_CONST_DICT(microlite_module_globals, microlite_module_globals_table);

// Define module object.
const mp_obj_module_t microlite_cmodule = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&microlite_module_globals,
};

// Register the module to make it available in Python.
MP_REGISTER_MODULE(MP_QSTR_microlite, microlite_cmodule, MODULE_MICROLITE_ENABLED);

