#include <algorithm>
#include <cstdint>
#include <cstring>

extern "C" {
#include "py/runtime.h"
#include "py/objarray.h"
#include "ndarray.h"
#include "tensorflow-microlite.h"
}

#include "audio_preprocessor_int8_model_data.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"

namespace {

constexpr int kAudioSampleFrequency = 16000;
constexpr int kFeatureSize = 40;
constexpr int kFeatureStrideMs = 20;
constexpr int kFeatureDurationMs = 30;
constexpr int kAudioSampleDurationCount =
    kFeatureDurationMs * kAudioSampleFrequency / 1000;
constexpr size_t kArenaSize = 16 * 1024;
constexpr size_t kArenaAlignment = 16;

using AudioPreprocessorOpResolver = tflite::MicroMutableOpResolver<18>;

struct EspAudioFrontendState {
  const tflite::Model* model;
  AudioPreprocessorOpResolver resolver;
  tflite::MicroInterpreter* interpreter;
  uint8_t raw_arena[kArenaSize + kArenaAlignment - 1];
  uint8_t* arena;

  EspAudioFrontendState()
      : model(nullptr), resolver(), interpreter(nullptr), raw_arena{}, arena(nullptr) {
    uintptr_t base = reinterpret_cast<uintptr_t>(raw_arena);
    uintptr_t aligned =
        (base + (kArenaAlignment - 1)) & ~(static_cast<uintptr_t>(kArenaAlignment) - 1);
    arena = reinterpret_cast<uint8_t*>(aligned);
  }
};

TfLiteStatus RegisterOps(AudioPreprocessorOpResolver& op_resolver) {
  TF_LITE_ENSURE_STATUS(op_resolver.AddReshape());
  TF_LITE_ENSURE_STATUS(op_resolver.AddCast());
  TF_LITE_ENSURE_STATUS(op_resolver.AddStridedSlice());
  TF_LITE_ENSURE_STATUS(op_resolver.AddConcatenation());
  TF_LITE_ENSURE_STATUS(op_resolver.AddMul());
  TF_LITE_ENSURE_STATUS(op_resolver.AddAdd());
  TF_LITE_ENSURE_STATUS(op_resolver.AddDiv());
  TF_LITE_ENSURE_STATUS(op_resolver.AddMinimum());
  TF_LITE_ENSURE_STATUS(op_resolver.AddMaximum());
  TF_LITE_ENSURE_STATUS(op_resolver.AddWindow());
  TF_LITE_ENSURE_STATUS(op_resolver.AddFftAutoScale());
  TF_LITE_ENSURE_STATUS(op_resolver.AddRfft());
  TF_LITE_ENSURE_STATUS(op_resolver.AddEnergy());
  TF_LITE_ENSURE_STATUS(op_resolver.AddFilterBank());
  TF_LITE_ENSURE_STATUS(op_resolver.AddFilterBankSquareRoot());
  TF_LITE_ENSURE_STATUS(op_resolver.AddFilterBankSpectralSubtraction());
  TF_LITE_ENSURE_STATUS(op_resolver.AddPCAN());
  TF_LITE_ENSURE_STATUS(op_resolver.AddFilterBankLog());
  return kTfLiteOk;
}

EspAudioFrontendState* get_backend(microlite_audio_frontend_obj_t* self) {
  return static_cast<EspAudioFrontendState*>(self->state);
}

EspAudioFrontendState* ensure_backend(microlite_audio_frontend_obj_t* self) {
  auto* backend = get_backend(self);
  if (backend == nullptr) {
    backend = new EspAudioFrontendState();
    self->state = backend;
  }
  return backend;
}

TfLiteStatus ensure_initialized(EspAudioFrontendState* backend) {
  if (backend->interpreter != nullptr) {
    return kTfLiteOk;
  }

  backend->model = tflite::GetModel(g_audio_preprocessor_int8_tflite);
  if (backend->model->version() != TFLITE_SCHEMA_VERSION) {
    return kTfLiteError;
  }

  TF_LITE_ENSURE_STATUS(RegisterOps(backend->resolver));

  backend->interpreter = new tflite::MicroInterpreter(
      backend->model, backend->resolver, backend->arena, kArenaSize);

  if (backend->interpreter->AllocateTensors() != kTfLiteOk) {
    return kTfLiteError;
  }

  return kTfLiteOk;
}

}  // namespace

extern "C" mp_obj_t audio_frontend_configure(mp_obj_t self_in) {
  auto* self = static_cast<microlite_audio_frontend_obj_t*>(MP_OBJ_TO_PTR(self_in));
  auto* backend = ensure_backend(self);

  if (ensure_initialized(backend) != kTfLiteOk) {
    mp_raise_TypeError(MP_ERROR_TEXT("Failed to initialize ESP audio frontend"));
  }

  return mp_const_none;
}

extern "C" mp_obj_t audio_frontend_execute(mp_obj_t self_in, mp_obj_t input) {
  auto* self = static_cast<microlite_audio_frontend_obj_t*>(MP_OBJ_TO_PTR(self_in));
  auto* backend = ensure_backend(self);
  auto* frontend_input = static_cast<ndarray_obj_t*>(MP_OBJ_TO_PTR(input));

  if (ensure_initialized(backend) != kTfLiteOk) {
    mp_raise_TypeError(MP_ERROR_TEXT("Audio frontend is not configured"));
  }

  if (frontend_input->len < kAudioSampleDurationCount) {
    mp_raise_ValueError(MP_ERROR_TEXT("audio segment too short"));
  }

  TfLiteTensor* input_tensor = backend->interpreter->input(0);
  TfLiteTensor* output_tensor = backend->interpreter->output(0);

  auto* input_data = tflite::GetTensorData<int16_t>(input_tensor);
  auto* output_data = tflite::GetTensorData<int8_t>(output_tensor);
  auto* source = static_cast<int16_t*>(frontend_input->array);

  std::copy_n(source, kAudioSampleDurationCount, input_data);

  if (backend->interpreter->Invoke() != kTfLiteOk) {
    mp_raise_TypeError(MP_ERROR_TEXT("ESP audio frontend execution failed"));
  }

  ndarray_obj_t* micro_features_output =
      ndarray_new_linear_array(kFeatureSize, NDARRAY_INT8);

  std::memcpy(micro_features_output->array, output_data, kFeatureSize);

  return MP_OBJ_FROM_PTR(micro_features_output);
}
