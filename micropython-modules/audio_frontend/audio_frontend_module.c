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

// ulab
#include "ndarray.h"

// tensorflow
#include "tensorflow/lite/experimental/microfrontend/lib/frontend.h"
#include "tensorflow/lite/experimental/microfrontend/lib/frontend_util.h"

// this brings in the constannts used within the config.
// later we will set these in python and pass in.
#include "tensorflow/lite/micro/examples/micro_speech/micro_features/micro_model_settings.h"

STATIC struct FrontendConfig config;
STATIC struct FrontendState state;


STATIC mp_obj_t configure (size_t n_args, size_t n_kw, const mp_obj_t *args) {

//  mp_arg_check_num(n_args, n_kw, 5, 5, true);

    // Copied from: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/lite/micro/examples/micro_speech/micro_features/micro_features_generator.cc

  // the 3 variables pass through from the micro_speech micro_model_settings.h file imported above
  // this is temporary and we will make them pass through micropython as a next step.
  config.window.size_ms = kFeatureSliceDurationMs;
  config.window.step_size_ms = kFeatureSliceStrideMs;
  config.noise_reduction.smoothing_bits = 10;
  config.filterbank.num_channels = kFeatureSliceSize;
  config.filterbank.lower_band_limit = 125.0;
  config.filterbank.upper_band_limit = 7500.0;
  config.noise_reduction.smoothing_bits = 10;
  config.noise_reduction.even_smoothing = 0.025;
  config.noise_reduction.odd_smoothing = 0.06;
  config.noise_reduction.min_signal_remaining = 0.05;
  config.pcan_gain_control.enable_pcan = 1;
  config.pcan_gain_control.strength = 0.95;
  config.pcan_gain_control.offset = 80.0;
  config.pcan_gain_control.gain_bits = 21;
  config.log_scale.enable_log = 1;
  config.log_scale.scale_shift = 6;

    if (!FrontendPopulateState(&config, &state,
                             kAudioSampleFrequency)) {
        mp_raise_TypeError("Failed to setup the frontend state");
    }

    return mp_const_none;
}

MP_DEFINE_CONST_FUN_OBJ_KW(audio_frontend_configure, 1, configure);

STATIC mp_obj_t execute (size_t n_args, size_t n_kw, const mp_obj_t *args) {

  mp_arg_check_num(n_args, n_kw, 2, 2, false);

//  copied from tensorflow:
//  tensorflow/tensorflow/lite/micro/examples/micro_speech/micro_features/micro_features_generator.cc

//  TfLiteStatus GenerateMicroFeatures(tflite::ErrorReporter* error_reporter,
//                                     const int16_t* input, int input_size,
//                                     int output_size, int8_t* output,
//                                     size_t* num_samples_read) {
    ndarray_obj_t *frontend_input = MP_OBJ_TO_PTR(args[0]);

    ndarray_obj_t *micro_features_output = MP_OBJ_TO_PTR(args[1]);

//    frontend_input.dtype == int16_t

//    const int16_t* frontend_input;
//    if (g_is_first_time) {
//      frontend_input = input;
//      g_is_first_time = false;
//    } else {
//      frontend_input = input + 160;
//    }

    int num_samples_read = 0;

    FrontendOutput frontend_output = FrontendProcessSamples(
        &state, frontend_input->array, frontend_input->len, &num_samples_read);

     mp_print_str(MP_PYTHON_PRINTER, "num_samples_read %d", num_samples_read);

    for (size_t i = 0; i < frontend_output.size; ++i) {
      // These scaling values are derived from those used in input_data.py in the
      // training pipeline.
      // The feature pipeline outputs 16-bit signed integers in roughly a 0 to 670
      // range. In training, these are then arbitrarily divided by 25.6 to get
      // float values in the rough range of 0.0 to 26.0. This scaling is performed
      // for historical reasons, to match up with the output of other feature
      // generators.
      // The process is then further complicated when we quantize the model. This
      // means we have to scale the 0.0 to 26.0 real values to the -128 to 127
      // signed integer numbers.
      // All this means that to get matching values from our integer feature
      // output into the tensor input, we have to perform:
      // input = (((feature / 25.6) / 26.0) * 256) - 128
      // To simplify this and perform it in 32-bit integer math, we rearrange to:
      // input = (feature * 256) / (25.6 * 26.0) - 128
      constexpr int32_t value_scale = 256;
      constexpr int32_t value_div = static_cast<int32_t>((25.6f * 26.0f) + 0.5f);
      int32_t value =
          ((frontend_output.values[i] * value_scale) + (value_div / 2)) /
          value_div;
      value -= 128;
      if (value < -128) {
        value = -128;
      }
      if (value > 127) {
        value = 127;
      }
      // I may need to cast this
      // and also make sure the output is of size int16
        micro_features_output->array[i] = value;
    }

    return mp_const_none;
}

MP_DEFINE_CONST_FUN_OBJ_KW(audio_frontend_execute, 1, execute);

// audio_frontend module

// Define all properties of the module.
// Table entries are key/value pairs of the attribute name (a string)
// and the MicroPython object reference.
// All identifiers and strings are written as MP_QSTR_xxx and will be
// optimized to word-sized integers by the build system (interned strings).
STATIC const mp_rom_map_elem_t microlite_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_audio_frontend) },
    { MP_ROM_QSTR(MP_QSTR_execute), MP_ROM_PTR(&audio_frontend_execute) },
    { MP_ROM_QSTR(MP_QSTR_configure), MP_ROM_PTR(&audio_frontend_configure) }
};
STATIC MP_DEFINE_CONST_DICT(audio_frontend_module_globals, audio_frontend_module_globals_table);

// Define module object.
const mp_obj_module_t audio_frontend_cmodule = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&audio_frontend_module_globals,
};

// Register the module to make it available in Python.
MP_REGISTER_MODULE(MP_QSTR_audio_frontend, audio_frontend_cmodule, MODULE_AUDIO_FRONTEND_ENABLED);

