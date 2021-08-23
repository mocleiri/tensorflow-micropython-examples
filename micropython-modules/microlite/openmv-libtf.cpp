/* This file is part of the OpenMV project.
 * Copyright (c) 2013-2019 Ibrahim Abdelkader <iabdalkader@openmv.io> & Kwabena W. Agyeman <kwagyeman@openmv.io>
 * This work is licensed under the MIT license, see the file LICENSE for details.
 */

#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

#include "tensorflow-microlite.h"
#include "openmv-libtf.h"
#include "micropython-error-reporter.h"
#include <stdio.h>

extern "C" {

    STATIC microlite::MicropythonErrorReporter micro_error_reporter;
    

    
/*
 Return the index'th tensor
 */
    TfLiteTensor *libtf_interpreter_get_input_tensor(microlite_interpreter_obj_t *microlite_interpreter, mp_uint_t index) {

        tflite::MicroInterpreter *interpreter = (tflite::MicroInterpreter *)microlite_interpreter->tf_interpreter;

        return interpreter->input((size_t)index);
        
    }

    TfLiteTensor *libtf_interpreter_get_output_tensor(microlite_interpreter_obj_t *microlite_interpreter, mp_uint_t index) {
                
        tflite::MicroInterpreter *interpreter = (tflite::MicroInterpreter *)microlite_interpreter->tf_interpreter;

        return interpreter->output((size_t)index);
    }

    // static int libtf_align_tensor_arena(uint8_t **tensor_arena, size_t *tensor_arena_size)
    // {
    //      tflite::ErrorReporter *error_reporter = &micro_error_reporter;

    //      error_reporter->Report("Performing Alignment");
    //      uint8_t alignment = ((uint8_t) (*tensor_arena)) % 16;

    //      if (alignment) {

    //          unsigned int fix = 16 - alignment;

    //          if ((*tensor_arena_size) < fix) {
    //              return 1;
    //          }

    //          (*tensor_arena) += fix;
    //          (*tensor_arena_size) -= fix;
    //      }

    //      return 0;
    //  }

    STATIC tflite::MicroMutableOpResolver<MICROLITE_TOTAL_OPS> tf_op_resolver;

    int libtf_interpreter_init(microlite_interpreter_obj_t *microlite_interpreter) {

        tflite::ErrorReporter *error_reporter = &micro_error_reporter;

        const tflite::Model *model = tflite::GetModel(microlite_interpreter->model_data->items);

//        if (model->version() != TFLITE_SCHEMA_VERSION) {
//            error_reporter->Report("Model provided is schema version is not equal to supported version!");
//            return 1;
//        }

        // if (libtf_align_tensor_arena((uint8_t **)microlite_interpreter->tensor_area->items, &microlite_interpreter->tensor_area->len)) {
        //      error_reporter->Report("Align failed!");
        //      return 1;
        //  }


        libtf_op_resolver_init(&tf_op_resolver);

        microlite_interpreter->tf_error_reporter = (mp_obj_t)error_reporter;
        microlite_interpreter->tf_model = (mp_obj_t)model;


        // tflite::MicroAllocator *allocator = tflite::MicroAllocator::Create(
        //     (uint8_t*)microlite_interpreter->tensor_area->items, 
        //     microlite_interpreter->tensor_area->len, error_reporter);

        tflite::AllOpsResolver resolver;
        tflite::MicroInterpreter *interpreter = new tflite::MicroInterpreter(model, 
                                             tf_op_resolver,
                                             (uint8_t*)microlite_interpreter->tensor_area->items, 
                                             microlite_interpreter->tensor_area->len, 
                                             error_reporter);

        if (interpreter->AllocateTensors() != kTfLiteOk) {
            error_reporter->Report("AllocateTensors() failed!");
            return 1;
        }

        microlite_interpreter->tf_interpreter = (mp_obj_t)interpreter;

        return 0;
    }

    int libtf_interpreter_invoke(microlite_interpreter_obj_t *microlite_interpreter)
    {
        
        tflite::ErrorReporter *error_reporter = (tflite::ErrorReporter *)microlite_interpreter->tf_error_reporter;

        tflite::MicroInterpreter *interpreter = (tflite::MicroInterpreter *)microlite_interpreter->tf_interpreter;

        mp_call_function_1(microlite_interpreter->input_callback, microlite_interpreter);

        if (interpreter->Invoke() != kTfLiteOk) {
            error_reporter->Report("Invoke() failed!");
            return 1;
        }

        mp_call_function_1(microlite_interpreter->output_callback, microlite_interpreter);

        return 0;
    }

}
