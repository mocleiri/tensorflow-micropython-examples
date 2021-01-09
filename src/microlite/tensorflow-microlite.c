// Include MicroPython API.
#include "py/runtime.h"
#include "py/mpprint.h"
#include "py/objstr.h"

#include "hello-world-microlite.h"
#include "openmv-libtf.h"

#include "tensorflow/lite/version.h"

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
    mp_arg_check_num(n_args, n_kw, 2, 2, true);
    microlite_interpreter_obj_t *self = m_new_obj(microlite_interpreter_obj_t);
    self->base.type = &microlite_interpreter_type;

//    self.model_data = mp_obj_new_bytes()
    // MP_DEFINE_STR_OBJ(obj_name, str)
    // obj.h mp_obj_t mp_obj_new_bytes(const byte *data, size_t len);
//    mp_obj_new_bytes
//    self->a = mp_obj_get_int(args[0]);
//    self->b = mp_obj_get_int(args[1]);
    return MP_OBJ_FROM_PTR(self);
}


STATIC void libtf_input_callback(void *callback_data,    void *model_input,
                                            const unsigned int input_height,
                                            const unsigned int input_width,
                                            const unsigned int input_channels,
                                            const bool signed_or_unsigned,
                                            const bool is_float) {
}

// Callback to use the model output data byte array (laid out in [height][width][channel] order).
STATIC void libtf_output_callback(void *callback_data,
                                             void *model_output,
                                             const unsigned int output_height,
                                             const unsigned int output_width,
                                             const unsigned int output_channels,
                                             const bool signed_or_unsigned, // True if output is int8_t ([-128:127]->[0:255]->[0.0f:1.0f]), False if output is uint8_t ([0:255]->[0:255]->[0.0f:1.0f]).
                                             const bool is_float) { // Actual is float32 (not optimal - network should be fixed). Output is [0.0f:+1.0f].
}

char input_callback_data[2048];
char output_callback_data[2048];

STATIC mp_obj_t interpreter_invoke(mp_obj_t self_in) {
    microlite_interpreter_obj_t *self = MP_OBJ_TO_PTR(self_in);

    int code = libtf_invoke(self->model_data->data,
                            self->tensor_area->data,
                            self->tensor_area->len,
                            &libtf_input_callback,
                            &input_callback_data,
                            &libtf_output_callback,
                            &output_callback_data);

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

