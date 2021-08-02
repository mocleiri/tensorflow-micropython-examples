/* This file is part of the OpenMV project.
 * Copyright (c) 2013-2019 Ibrahim Abdelkader <iabdalkader@openmv.io> & Kwabena W. Agyeman <kwagyeman@openmv.io>
 * This work is licensed under the MIT license, see the file LICENSE for details.
 */

#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "tensorflow/lite/version.h"
#include "tensorflow/lite/micro/examples/micro_speech/micro_features/micro_features_generator.h"

#include "tensorflow-microlite.h"
#include "openmv-libtf.h"
#include "micropython-error-reporter.h"
#include <stdio.h>

extern "C" {

   /*
    * Return the index'th tensor
    */
    TfLiteTensor *libtf_get_input_tensor(microlite_interpreter_obj_t *microlite_interpreter, mp_uint_t index) {

        tflite::MicroInterpreter *interpreter = (tflite::MicroInterpreter *)microlite_interpreter->tf_interpreter;

        return interpreter->input((size_t)index);
        
    }

    TfLiteTensor *libtf_get_output_tensor(microlite_interpreter_obj_t *microlite_interpreter, mp_uint_t index) {
                
        tflite::MicroInterpreter *interpreter = (tflite::MicroInterpreter *)microlite_interpreter->tf_interpreter;

        return interpreter->output((size_t)index);
    }


    STATIC microlite::MicropythonErrorReporter micro_error_reporter;

    int libtf_init(microlite_interpreter_obj_t *microlite_interpretor) {

        tflite::ErrorReporter *error_reporter = &micro_error_reporter;

        const tflite::Model *model = tflite::GetModel(microlite_interpretor->model_data->items);

        if (model->version() != TFLITE_SCHEMA_VERSION) {
            error_reporter->Report("Model provided is schema version is not equal to supported version!");
            return 1;
        }

        microlite_interpretor->tf_error_reporter = (mp_obj_t)error_reporter;
        microlite_interpretor->tf_model = (mp_obj_t)model;
       

        return 0;
    }

    int libtf_invoke(microlite_interpreter_obj_t *microlite_interpretor)
    {
        
        tflite::ErrorReporter *error_reporter = (tflite::ErrorReporter *)microlite_interpretor->tf_error_reporter;

        const tflite::Model *model = (const tflite::Model *)microlite_interpretor->tf_model;

        tflite::AllOpsResolver resolver;
        tflite::MicroInterpreter interpreter(model, 
                                             resolver, 
                                             (unsigned char*)microlite_interpretor->tensor_area->items, 
                                             microlite_interpretor->tensor_area->len, 
                                             error_reporter);

        if (interpreter.AllocateTensors() != kTfLiteOk) {
            error_reporter->Report("AllocateTensors() failed!");
            return 1;
        }

        // the interpreter is only good within this function scope
        microlite_interpretor->tf_interpreter = (mp_obj_t)&interpreter;

        mp_call_function_1(microlite_interpretor->input_callback, microlite_interpretor);

        if (interpreter.Invoke() != kTfLiteOk) {
            error_reporter->Report("Invoke() failed!");
            microlite_interpretor->tf_interpreter = mp_const_none;
            return 1;
        }

        mp_call_function_1(microlite_interpretor->output_callback, microlite_interpretor);

        // reset the interpreter after the results have been retrieved
        microlite_interpretor->tf_interpreter = mp_const_none;

        return 0;
    }

}
