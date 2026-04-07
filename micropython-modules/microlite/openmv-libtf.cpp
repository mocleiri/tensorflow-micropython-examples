/* This file is part of the OpenMV project.
 * Copyright (c) 2013-2019 Ibrahim Abdelkader <iabdalkader@openmv.io> & Kwabena W. Agyeman <kwagyeman@openmv.io>
 * This work is licensed under the MIT license, see the file LICENSE for details.
 */

#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

#include "tensorflow-microlite.h"
#include "openmv-libtf.h"
#include "micropython-error-reporter.h"
#include <stdio.h>

extern "C" {

    static microlite::MicropythonErrorReporter micro_error_reporter;

    using MicroliteAllOpsResolver = tflite::MicroMutableOpResolver<98>;

    static TfLiteStatus libtf_populate_op_resolver(MicroliteAllOpsResolver &resolver) {
        TF_LITE_ENSURE_STATUS(resolver.AddAbs());
        TF_LITE_ENSURE_STATUS(resolver.AddAdd());
        TF_LITE_ENSURE_STATUS(resolver.AddAddN());
        TF_LITE_ENSURE_STATUS(resolver.AddArgMax());
        TF_LITE_ENSURE_STATUS(resolver.AddArgMin());
        TF_LITE_ENSURE_STATUS(resolver.AddAssignVariable());
        TF_LITE_ENSURE_STATUS(resolver.AddAveragePool2D());
        TF_LITE_ENSURE_STATUS(resolver.AddBatchToSpaceNd());
        TF_LITE_ENSURE_STATUS(resolver.AddBroadcastArgs());
        TF_LITE_ENSURE_STATUS(resolver.AddBroadcastTo());
        TF_LITE_ENSURE_STATUS(resolver.AddCallOnce());
        TF_LITE_ENSURE_STATUS(resolver.AddCast());
        TF_LITE_ENSURE_STATUS(resolver.AddCeil());
        TF_LITE_ENSURE_STATUS(resolver.AddCircularBuffer());
        TF_LITE_ENSURE_STATUS(resolver.AddConcatenation());
        TF_LITE_ENSURE_STATUS(resolver.AddConv2D());
        TF_LITE_ENSURE_STATUS(resolver.AddCos());
        TF_LITE_ENSURE_STATUS(resolver.AddCumSum());
        TF_LITE_ENSURE_STATUS(resolver.AddDepthToSpace());
        TF_LITE_ENSURE_STATUS(resolver.AddDepthwiseConv2D());
        TF_LITE_ENSURE_STATUS(resolver.AddDequantize());
        TF_LITE_ENSURE_STATUS(resolver.AddDetectionPostprocess());
        TF_LITE_ENSURE_STATUS(resolver.AddDiv());
        TF_LITE_ENSURE_STATUS(resolver.AddElu());
        TF_LITE_ENSURE_STATUS(resolver.AddEqual());
        TF_LITE_ENSURE_STATUS(resolver.AddEthosU());
        TF_LITE_ENSURE_STATUS(resolver.AddExp());
        TF_LITE_ENSURE_STATUS(resolver.AddExpandDims());
        TF_LITE_ENSURE_STATUS(resolver.AddFill());
        TF_LITE_ENSURE_STATUS(resolver.AddFloor());
        TF_LITE_ENSURE_STATUS(resolver.AddFloorDiv());
        TF_LITE_ENSURE_STATUS(resolver.AddFloorMod());
        TF_LITE_ENSURE_STATUS(resolver.AddFullyConnected());
        TF_LITE_ENSURE_STATUS(resolver.AddGather());
        TF_LITE_ENSURE_STATUS(resolver.AddGatherNd());
        TF_LITE_ENSURE_STATUS(resolver.AddGreater());
        TF_LITE_ENSURE_STATUS(resolver.AddGreaterEqual());
        TF_LITE_ENSURE_STATUS(resolver.AddHardSwish());
        TF_LITE_ENSURE_STATUS(resolver.AddIf());
        TF_LITE_ENSURE_STATUS(resolver.AddL2Normalization());
        TF_LITE_ENSURE_STATUS(resolver.AddL2Pool2D());
        TF_LITE_ENSURE_STATUS(resolver.AddLeakyRelu());
        TF_LITE_ENSURE_STATUS(resolver.AddLess());
        TF_LITE_ENSURE_STATUS(resolver.AddLessEqual());
        TF_LITE_ENSURE_STATUS(resolver.AddLog());
        TF_LITE_ENSURE_STATUS(resolver.AddLogicalAnd());
        TF_LITE_ENSURE_STATUS(resolver.AddLogicalNot());
        TF_LITE_ENSURE_STATUS(resolver.AddLogicalOr());
        TF_LITE_ENSURE_STATUS(resolver.AddLogistic());
        TF_LITE_ENSURE_STATUS(resolver.AddLogSoftmax());
        TF_LITE_ENSURE_STATUS(resolver.AddMaxPool2D());
        TF_LITE_ENSURE_STATUS(resolver.AddMaximum());
        TF_LITE_ENSURE_STATUS(resolver.AddMean());
        TF_LITE_ENSURE_STATUS(resolver.AddMinimum());
        TF_LITE_ENSURE_STATUS(resolver.AddMirrorPad());
        TF_LITE_ENSURE_STATUS(resolver.AddMul());
        TF_LITE_ENSURE_STATUS(resolver.AddNeg());
        TF_LITE_ENSURE_STATUS(resolver.AddNotEqual());
        TF_LITE_ENSURE_STATUS(resolver.AddPack());
        TF_LITE_ENSURE_STATUS(resolver.AddPad());
        TF_LITE_ENSURE_STATUS(resolver.AddPadV2());
        TF_LITE_ENSURE_STATUS(resolver.AddPrelu());
        TF_LITE_ENSURE_STATUS(resolver.AddQuantize());
        TF_LITE_ENSURE_STATUS(resolver.AddReadVariable());
        TF_LITE_ENSURE_STATUS(resolver.AddReduceMax());
        TF_LITE_ENSURE_STATUS(resolver.AddReduceMin());
        TF_LITE_ENSURE_STATUS(resolver.AddRelu());
        TF_LITE_ENSURE_STATUS(resolver.AddRelu6());
        TF_LITE_ENSURE_STATUS(resolver.AddReshape());
        TF_LITE_ENSURE_STATUS(resolver.AddResizeBilinear());
        TF_LITE_ENSURE_STATUS(resolver.AddResizeNearestNeighbor());
        TF_LITE_ENSURE_STATUS(resolver.AddRound());
        TF_LITE_ENSURE_STATUS(resolver.AddRsqrt());
        TF_LITE_ENSURE_STATUS(resolver.AddSelectV2());
        TF_LITE_ENSURE_STATUS(resolver.AddShape());
        TF_LITE_ENSURE_STATUS(resolver.AddSin());
        TF_LITE_ENSURE_STATUS(resolver.AddSlice());
        TF_LITE_ENSURE_STATUS(resolver.AddSoftmax());
        TF_LITE_ENSURE_STATUS(resolver.AddSpaceToBatchNd());
        TF_LITE_ENSURE_STATUS(resolver.AddSpaceToDepth());
        TF_LITE_ENSURE_STATUS(resolver.AddSplit());
        TF_LITE_ENSURE_STATUS(resolver.AddSplitV());
        TF_LITE_ENSURE_STATUS(resolver.AddSqrt());
        TF_LITE_ENSURE_STATUS(resolver.AddSquare());
        TF_LITE_ENSURE_STATUS(resolver.AddSquaredDifference());
        TF_LITE_ENSURE_STATUS(resolver.AddSqueeze());
        TF_LITE_ENSURE_STATUS(resolver.AddStridedSlice());
        TF_LITE_ENSURE_STATUS(resolver.AddSub());
        TF_LITE_ENSURE_STATUS(resolver.AddSum());
        TF_LITE_ENSURE_STATUS(resolver.AddSvdf());
        TF_LITE_ENSURE_STATUS(resolver.AddTanh());
        TF_LITE_ENSURE_STATUS(resolver.AddTranspose());
        TF_LITE_ENSURE_STATUS(resolver.AddTransposeConv());
        TF_LITE_ENSURE_STATUS(resolver.AddUnidirectionalSequenceLSTM());
        TF_LITE_ENSURE_STATUS(resolver.AddUnpack());
        TF_LITE_ENSURE_STATUS(resolver.AddVarHandle());
        TF_LITE_ENSURE_STATUS(resolver.AddWhile());
        TF_LITE_ENSURE_STATUS(resolver.AddZerosLike());
        return kTfLiteOk;
    }
    

    
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


        microlite_interpreter->tf_error_reporter = (mp_obj_t)error_reporter;
        microlite_interpreter->tf_model = (mp_obj_t)model;


        // tflite::MicroAllocator *allocator = tflite::MicroAllocator::Create(
        //     (uint8_t*)microlite_interpreter->tensor_area->items, 
        //     microlite_interpreter->tensor_area->len, error_reporter);

        static MicroliteAllOpsResolver resolver;
        static bool resolver_initialized = false;
        if (!resolver_initialized) {
            if (libtf_populate_op_resolver(resolver) != kTfLiteOk) {
                error_reporter->Report("Failed to populate op resolver!");
                return 1;
            }
            resolver_initialized = true;
        }
        tflite::MicroInterpreter *interpreter = new tflite::MicroInterpreter(model, 
                                             resolver, 
                                             (uint8_t*)microlite_interpreter->tensor_area->items, 
                                             microlite_interpreter->tensor_area->len);

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
