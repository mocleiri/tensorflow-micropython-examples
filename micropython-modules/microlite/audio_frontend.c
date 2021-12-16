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
//#include <bits/stdint-intn.h>

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

#include "tensorflow-microlite.h"

// tensorflow
#include "tensorflow/lite/experimental/microfrontend/lib/frontend.h"
#include "tensorflow/lite/experimental/microfrontend/lib/frontend_util.h"

// this brings in the constannts used within the config.
// later we will set these in python and pass in.
// #include "tensorflow/lite/micro/examples/micro_speech/micro_features/micro_model_settings.h"

// }

// Keeping these as constant expressions allow us to allocate fixed-sized arrays
// on the stack for our working memory.

// The size of the input time series data we pass to the FFT to produce the
// frequency information. This has to be a power of two, and since we're dealing
// with 30ms of 16KHz inputs, which means 480 samples, this is the next value.
static const int kMaxAudioSampleSize = 512;
static const int kAudioSampleFrequency = 16000;

// The following values are derived from values used during model training.
// If you change the way you preprocess the input, update all these constants.
static const int kFeatureSliceSize = 40;
static const int kFeatureSliceCount = 49;
static const int kFeatureElementCount =  40*49; // (kFeatureSliceSize * kFeatureSliceCount);
static const int kFeatureSliceStrideMs = 20;
static const int kFeatureSliceDurationMs = 30;


mp_obj_t audio_frontend_configure (mp_obj_t self_in) {

microlite_audio_frontend_obj_t*self = MP_OBJ_TO_PTR(self_in);

//  mp_arg_check_num(n_args, n_kw, 5, 5, true);

    // Copied from: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/lite/micro/examples/micro_speech/micro_features/micro_features_generator.cc

  // TODO externalize this into a type where these different values can be configured.

  // the 3 variables pass through from the micro_speech micro_model_settings.h file imported above
  // this is temporary and we will make them pass through micropython as a next step.
  self->config->window.size_ms = kFeatureSliceDurationMs;
  self->config->window.step_size_ms = kFeatureSliceStrideMs;
  self->config->noise_reduction.smoothing_bits = 10;
  self->config->filterbank.num_channels = kFeatureSliceSize;
  self->config->filterbank.lower_band_limit = 125.0;
  self->config->filterbank.upper_band_limit = 7500.0;
  self->config->noise_reduction.smoothing_bits = 10;
  self->config->noise_reduction.even_smoothing = 0.025;
  self->config->noise_reduction.odd_smoothing = 0.06;
  self->config->noise_reduction.min_signal_remaining = 0.05;
  self->config->pcan_gain_control.enable_pcan = 1;
  self->config->pcan_gain_control.strength = 0.95;
  self->config->pcan_gain_control.offset = 80.0;
  self->config->pcan_gain_control.gain_bits = 21;
  self->config->log_scale.enable_log = 1;
  self->config->log_scale.scale_shift = 6;

    if (!FrontendPopulateState(self->config, self->state,
                             kAudioSampleFrequency)) {
        mp_raise_TypeError("Failed to setup the frontend state");
    }

    return mp_const_none;
}

static int32_t value_scale = 256;
static int32_t value_div = (int32_t)((25.6f * 26.0f) + 0.5f);

mp_obj_t audio_frontend_execute (mp_obj_t self_in, mp_obj_t input) {

  microlite_audio_frontend_obj_t*self = MP_OBJ_TO_PTR(self_in);

  ndarray_obj_t *frontend_input = MP_OBJ_TO_PTR(input);

  size_t num_samples_read = 0;

  // we expect a new slice of audio to be passed each time
  // but FrontendProcessSamples will window to 320 bytes on each subsequent call
  // so reset back to zero so that the whole fronend_input array is processed each time.
  
  self->state->window.input_used = 0;

  struct FrontendOutput frontend_output = FrontendProcessSamples(
      self->state, frontend_input->array, frontend_input->len, &num_samples_read);

    //  mp_printf(MP_PYTHON_PRINTER, "num_samples_read %d\n", num_samples_read);

    ndarray_obj_t *micro_features_output = ndarray_new_linear_array(frontend_output.size, NDARRAY_INT8);

    int8_t *output_array = (int8_t *)micro_features_output->array;

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
      output_array[i] = (int8_t)value;
    }

    return MP_OBJ_FROM_PTR(micro_features_output);
}



