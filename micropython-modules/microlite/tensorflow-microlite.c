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

#include "openmv-libtf.h"

#include "tensorflow/lite/c/common.h"

// #if MICROPY_PY_MICROLITE 

const mp_obj_type_t microlite_interpreter_type;
const mp_obj_type_t microlite_tensor_type;
const mp_obj_type_t microlite_audio_frontend_type;

STATIC mp_obj_t interpreter_get_input_tensor(mp_obj_t self_in, mp_obj_t index_obj);

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

    const char *type = TfLiteTypeGetName(tensor->type);

    return mp_obj_new_str(type, strlen(type));

}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_tensor_get_tensor_type, tensor_get_tensor_type);


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

MP_DEFINE_CONST_OBJ_TYPE(
    microlite_tensor_type,
    MP_QSTR_tensor,
    MP_TYPE_FLAG_NONE,
    print, tensor_print,
    locals_dict,&tensor_locals_dict
);
// audio_frontend

STATIC mp_obj_t af_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    mp_arg_check_num(n_args, n_kw, 0, 0, false);

    microlite_audio_frontend_obj_t*single_audio_frontend = m_new_obj(microlite_audio_frontend_obj_t);

    single_audio_frontend->config = m_malloc(sizeof(struct FrontendConfig));
    single_audio_frontend->state = m_malloc(sizeof(struct FrontendState));

    single_audio_frontend->base.type = &microlite_audio_frontend_type;

    return MP_OBJ_FROM_PTR(single_audio_frontend);
}

STATIC void af_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    (void)kind;
    // microlite_tensor_obj_t *self = MP_OBJ_TO_PTR(self_in);

    // TfLiteTensor * tensor = (TfLiteTensor *)self->tf_tensor;

    mp_print_str(print, "audio_frontend(type=");

    // mp_print_str(print, TfLiteTypeGetName(tensor->type));

    // int size = tensor->dims->size;

    // mp_printf(print, ", dims->size=%d\n", size);

    mp_print_str(print, ")\n");
}

MP_DEFINE_CONST_FUN_OBJ_1(af_configure, audio_frontend_configure);
MP_DEFINE_CONST_FUN_OBJ_2(af_execute, audio_frontend_execute);

STATIC const mp_rom_map_elem_t audio_frontend_locals_dict_table[] = {
   { MP_ROM_QSTR(MP_QSTR_execute), MP_ROM_PTR(&af_execute) },
   { MP_ROM_QSTR(MP_QSTR_configure), MP_ROM_PTR(&af_configure) }
};

STATIC MP_DEFINE_CONST_DICT(audio_frontend_locals_dict, audio_frontend_locals_dict_table);

MP_DEFINE_CONST_OBJ_TYPE(
    microlite_audio_frontend_type,
    MP_QSTR_audio_frontend,
    MP_TYPE_FLAG_NONE,
    make_new, af_make_new,
    print, af_print,
    locals_dict, &audio_frontend_locals_dict
);

// - microlite interpreter

STATIC void interpreter_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) {
    (void)kind;
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);
    mp_print_str(print, "interpreter(");
    
    mp_printf(print, "model size = %d, tensor_area size = %d\n", self->model_data->len, self->tensor_area->len);
    
    microlite_tensor_obj_t *input_tensor = MP_OBJ_TO_PTR(interpreter_get_input_tensor(self, 0));

    microlite_tensor_obj_t *output_tensor = MP_OBJ_TO_PTR(interpreter_get_input_tensor(self, 0));

    mp_obj_print_helper (print, output_tensor, PRINT_STR);

    mp_print_str(print, ")");
}

STATIC mp_obj_t interpreter_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    mp_arg_check_num(n_args, n_kw, 4, 4, false);

//    args:
//      - model

//      - size of the tensor area
//      - input callback function
//      - output callback function

    mp_obj_array_t *model = MP_OBJ_TO_PTR (args[0]);

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

    self->inference_count = 0;

    self->base.type = &microlite_interpreter_type;



    // for now hard code the model to the hello world model
    // self->model_data = mp_obj_new_bytearray_by_ref(g_model_len, g_model);

    self->model_data = model;

// 

// add extra space to allow for alinment
    tensor_area_len  += 16;

    uint8_t *tensor_area_buffer = m_new(uint8_t, tensor_area_len);

    self->tensor_area = mp_obj_new_bytearray_by_ref (tensor_area_len, tensor_area_buffer);

    mp_printf(MP_PYTHON_PRINTER, "interpreter_make_new: model size = %d, tensor area = %d\n", self->model_data->len, tensor_area_len);

    libtf_interpreter_init(self);

    return MP_OBJ_FROM_PTR(self);
}

// called before passing the tensor to the callback
STATIC mp_obj_t interpreter_get_input_tensor(mp_obj_t self_in, mp_obj_t index_obj) {

    mp_uint_t index = mp_obj_int_get_uint_checked(index_obj);

    microlite_interpreter_obj_t *microlite_interpreter = MP_OBJ_TO_PTR(self_in);

    microlite_tensor_obj_t *microlite_tensor = m_new_obj(microlite_tensor_obj_t);

    TfLiteTensor *input_tensor = libtf_interpreter_get_input_tensor(microlite_interpreter, index);

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

    TfLiteTensor *output_tensor = libtf_interpreter_get_output_tensor(microlite_interpreter, index);

    microlite_tensor->tf_tensor = output_tensor;
    microlite_tensor->microlite_interpreter = microlite_interpreter;
    microlite_tensor->base.type = &microlite_tensor_type;

    return MP_OBJ_FROM_PTR(microlite_tensor);
}

MP_DEFINE_CONST_FUN_OBJ_2(microlite_interpreter_get_output_tensor, interpreter_get_output_tensor);

STATIC mp_obj_t interpreter_invoke(mp_obj_t self_in) {
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);

    
    int code = libtf_interpreter_invoke(self);

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

MP_DEFINE_CONST_OBJ_TYPE(
    microlite_interpreter_type,
    MP_QSTR_interpreter,
    MP_TYPE_FLAG_NONE,
    print, interpreter_print,
    make_new, interpreter_make_new,
    locals_dict, &interpreter_locals_dict
);

// main microlite module

// needs to be manually updated when the firmware is built.
// see if we can pass through the project git commit when this is run.
STATIC const MP_DEFINE_STR_OBJ(microlite_version_string_obj, TFLITE_MICRO_VERSION);

// Define all properties of the module.
// Table entries are key/value pairs of the attribute name (a string)
// and the MicroPython object reference.
// All identifiers and strings are written as MP_QSTR_xxx and will be
// optimized to word-sized integers by the build system (interned strings).
STATIC const mp_rom_map_elem_t microlite_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_microlite) },
    { MP_ROM_QSTR(MP_QSTR___version__), MP_ROM_PTR(&microlite_version_string_obj) },
    { MP_ROM_QSTR(MP_QSTR_interpreter), (mp_obj_t)&microlite_interpreter_type },
    { MP_ROM_QSTR(MP_QSTR_tensor), (mp_obj_t)&microlite_tensor_type },
    { MP_ROM_QSTR(MP_QSTR_audio_frontend), (mp_obj_t)&microlite_audio_frontend_type }

};
STATIC MP_DEFINE_CONST_DICT(microlite_module_globals, microlite_module_globals_table);

// Define module object.
const mp_obj_module_t microlite_cmodule = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&microlite_module_globals,
};

// Register the module to make it available in Python.
MP_REGISTER_MODULE(MP_QSTR_microlite, microlite_cmodule);

// #endif
