// Include MicroPython API.
#include "py/runtime.h"
#include "py/mpprint.h"
#include "py/objstr.h"
#include "py/objarray.h"
#include "py/mpprint.h"
#include "py/misc.h"

#include "hello-world-microlite.h"
#include "hello-world-model.h"

#include "openmv-libtf.h"

#include "tensorflow/lite/version.h"
#include "tensorflow/lite/c/common.h"

const mp_obj_type_t microlite_interpreter_type;

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
    mp_arg_check_num(n_args, n_kw, 1, 1, false);

//    args:
//      - model data
//      - model data length
//      - size of the tensor area

    int tensor_area_len = mp_obj_get_int(args[0]);

    // to start with just hard code to the hello-world model

    microlite_interpreter_obj_t *self = m_new_obj(microlite_interpreter_obj_t);
    self->base.type = &microlite_interpreter_type;

    // for now hard code the model to the hello world model
    self->model_data = mp_obj_new_bytearray_by_ref(g_model_len, g_model);

    byte *tensor_area_buffer = m_new(byte, tensor_area_len);

    self->tensor_area = mp_obj_new_bytearray_by_ref (tensor_area_len, tensor_area_buffer);

    mp_printf(MP_PYTHON_PRINTER, "interpreter_make_new: model size = %d, tensor area = %d", g_model_len, tensor_area_len);

    return MP_OBJ_FROM_PTR(self);
}

// these 2 are for the hello world example:
static int inference_count = 1;
const float kXrange = 2.f * 3.14159265359f;

STATIC void libtf_input_callback(TfLiteTensor *input) {

     mp_print_str(MP_PYTHON_PRINTER, "libtf_input_callback\n");

     // copied from example: https://www.tensorflow.org/lite/microcontrollers/get_started

     // Make sure the input has the properties we expect
//     TF_LITE_MICRO_EXPECT_NE(nullptr, input);
     // The property "dims" tells us the tensor's shape. It has one element for
     // each dimension. Our input is a 2D tensor containing 1 element, so "dims"
     // should have size 2.
//     TF_LITE_MICRO_EXPECT_EQ(2, input->dims->size);
     // The value of each element gives the length of the corresponding tensor.
     // We should expect two single element tensors (one is contained within the
     // other).
//     TF_LITE_MICRO_EXPECT_EQ(1, input->dims->data[0]);
//     TF_LITE_MICRO_EXPECT_EQ(1, input->dims->data[1]);
     // The input is a 32 bit floating point value
//     TF_LITE_MICRO_EXPECT_EQ(kTfLiteFloat32, input->type);

    float position = ((float)inference_count) / (float)1.0;

    float x = position * kXrange;

    // Quantize the input from floating-point to integer
      int8_t x_quantized = (int8_t)(x / input->params.scale + input->params.zero_point);
      // Place the quantized input in the model's input tensor
      input->data.int8[0] = x_quantized;

    mp_printf(MP_PYTHON_PRINTER, "input value : %d\n", x_quantized);
}

// Callback to use the model output data byte array (laid out in [height][width][channel] order).
STATIC void libtf_output_callback(TfLiteTensor *output) { // Actual is float32 (not optimal - network should be fixed). Output is [0.0f:+1.0f].

      mp_print_str(MP_PYTHON_PRINTER, "libtf_output_callback\n");

//      TF_LITE_MICRO_EXPECT_EQ(2, output->dims->size);
//      TF_LITE_MICRO_EXPECT_EQ(1, input->dims->data[0]);
//      TF_LITE_MICRO_EXPECT_EQ(1, input->dims->data[1]);
//      TF_LITE_MICRO_EXPECT_EQ(kTfLiteFloat32, output->type);

    // Obtain the quantized output from model's output tensor
    int8_t y_quantized = output->data.int8[0];

    // Dequantize the output from integer to floating-point
    float y = (y_quantized - output->params.zero_point) * output->params.scale;

    // Check that the output value is within 0.05 of the expected value
//    TF_LITE_MICRO_EXPECT_NEAR(0., value, 0.05);

    mp_printf(MP_PYTHON_PRINTER, "output value : %f\n", (double)y);

}

char input_callback_data[2048];
char output_callback_data[2048];

STATIC mp_obj_t interpreter_invoke(mp_obj_t self_in) {
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);

    int code = libtf_invoke(self->model_data->items,
                            self->tensor_area->items,
                            self->tensor_area->len,
                            &libtf_input_callback,
                            &input_callback_data,
                            &libtf_output_callback,
                            &output_callback_data);

    inference_count += 1;

    return mp_obj_new_int(code);
}

MP_DEFINE_CONST_FUN_OBJ_1(microlite_interpreter_invoke, interpreter_invoke);

// interpreter class
STATIC const mp_rom_map_elem_t interpreter_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_invoke), MP_ROM_PTR(&microlite_interpreter_invoke) },
};

STATIC MP_DEFINE_CONST_DICT(interpreter_locals_dict, interpreter_locals_dict_table);

const mp_obj_type_t microlite_interpreter_type = {
    { &mp_type_type },
    .name = MP_QSTR_interpreter,
    .print = interpreter_print,
    .make_new = interpreter_make_new,
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
    { MP_ROM_QSTR(MP_QSTR_interpreter), (mp_obj_t)&microlite_interpreter_type }
};
STATIC MP_DEFINE_CONST_DICT(microlite_module_globals, microlite_module_globals_table);

// Define module object.
const mp_obj_module_t microlite_cmodule = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&microlite_module_globals,
};

// Register the module to make it available in Python.
MP_REGISTER_MODULE(MP_QSTR_microlite, microlite_cmodule, MODULE_MICROLITE_ENABLED);

