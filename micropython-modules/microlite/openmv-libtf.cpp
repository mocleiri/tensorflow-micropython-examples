/* This file is part of the OpenMV project.
 * Copyright (c) 2013-2019 Ibrahim Abdelkader <iabdalkader@openmv.io> & Kwabena W. Agyeman <kwagyeman@openmv.io>
 * This work is licensed under the MIT license, see the file LICENSE for details.
 */

#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "tensorflow/lite/micro/examples/micro_speech/micro_features/micro_features_generator.h"

#include "tensorflow-microlite.h"
#include "openmv-libtf.h"
#include "micropython-error-reporter.h"
#include <stdio.h>

extern "C" {

//     static int libtf_align_tensor_arena(unsigned char **tensor_arena, unsigned int *tensor_arena_size)
//     {

//     // unix port doesn't like this code
// //        unsigned int alignment = ((unsigned int) (*tensor_arena)) % 16;
// //
// //        if (alignment) {
// //
// //            unsigned int fix = 16 - alignment;
// //
// //            if ((*tensor_arena_size) < fix) {
// //                return 1;
// //            }
// //
// //            (*tensor_arena) += fix;
// //            (*tensor_arena_size) -= fix;
// //        }

//         return 0;
//     }

/*
 Return the index'th tensor
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

    int libtf_init_op_resolver(microlite_op_resolver_obj_t *microlite_op_resolver) {

        if (microlite_op_resolver->mode == ALL_OPS) {

            tflite::AllOpsResolver* op_resolver = new tflite::AllOpsResolver();   

            microlite_op_resolver->tf_op_resolver = (mp_obj_t)op_resolver;
            

        }
        else if (microlite_op_resolver->mode == SPECIFIED_OPS) {
            // don't do anything
            tflite::MicroMutableOpResolver<MAX_TFLITE_OPS>* op_resolver = new tflite::MicroMutableOpResolver<MAX_TFLITE_OPS>(&micro_error_reporter);   

            microlite_op_resolver->tf_op_resolver = (mp_obj_t)op_resolver;
        }
        else {
            micro_error_reporter.Report("Op Resolver mode is invalid!");
        }

        return 0;
    }

    int libtf_init_interpreter(microlite_interpreter_obj_t *microlite_interpretor) {

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

    int libtf_op_resolver_add(microlite_op_resolver_obj_t *op_resolver, mp_int_t op_to_add) {
        
        if (op_resolver->mode != SPECIFIED_OPS) {
            micro_error_reporter.Report("Wrong mode.  Can only add more ops when in SPECIFIED_OPS mode!");
            return 1;
        }

        tflite::MicroMutableOpResolver<MAX_TFLITE_OPS> *tf_op_resolver = (tflite::MicroMutableOpResolver<MAX_TFLITE_OPS> *)op_resolver->tf_op_resolver;

        TfLiteStatus status;

        if (op_to_add == MicroliteOperator_ABS) {
            status = tf_op_resolver->AddAbs();
        }
        else if (op_to_add == MicroliteOperator_ADD) {
            status = tf_op_resolver->AddAdd();
        }
        else if (op_to_add == MicroliteOperator_ADD_N) {
            status = tf_op_resolver->AddAddN();
        }
        else if (op_to_add == MicroliteOperator_ARG_MAX) {
            status = tf_op_resolver->AddArgMax();
        }
        else if (op_to_add == MicroliteOperator_ARG_MIN) {
            status = tf_op_resolver->AddArgMin();
        }
        else if (op_to_add == MicroliteOperator_AVERAGE_POOL_2D) {
            status = tf_op_resolver->AddAveragePool2D();
        }
        else if (op_to_add == MicroliteOperator_BATCH_TO_SPACE_ND) {
            status = tf_op_resolver->AddBatchToSpaceNd();
        }
        else if (op_to_add == MicroliteOperator_CAST) {
            status = tf_op_resolver->AddCast();
        }
        else if (op_to_add == MicroliteOperator_CEIL) {
            status = tf_op_resolver->AddCeil();
        }
        else if (op_to_add == MicroliteOperator_CIRCULAR_BUFFER) {
            status = tf_op_resolver->AddCircularBuffer(); // custom
        }
        else if (op_to_add == MicroliteOperator_CONCATENATION) {
            status = tf_op_resolver->AddConcatenation();
        }
        else if (op_to_add == MicroliteOperator_CONV_2D) {
            status = tf_op_resolver->AddConv2D();
        }
        else if (op_to_add == MicroliteOperator_COS) {
            status = tf_op_resolver->AddCos();
        }
        else if (op_to_add == MicroliteOperator_CUMSUM) {  
            status = tf_op_resolver->AddCumSum();
        }
        else if (op_to_add == MicroliteOperator_DEPTH_TO_SPACE) {  
            status = tf_op_resolver->AddDepthToSpace();
        }
        else if (op_to_add == MicroliteOperator_DEPTHWISE_CONV_2D) {  
            status = tf_op_resolver->AddDepthwiseConv2D();
        }
        else if (op_to_add == MicroliteOperator_DEQUANTIZE) {  
            status = tf_op_resolver->AddDequantize();
        }
        else if (op_to_add == MicroliteOperator_DETECTION_POSTPROCESS) {  
            status = tf_op_resolver->AddDetectionPostprocess();  // custom
        }
        else if (op_to_add == MicroliteOperator_ELU) {  
            status = tf_op_resolver->AddElu(); 
        }
        else if (op_to_add == MicroliteOperator_EQUAL) {  
            status = tf_op_resolver->AddEqual(); 
        }
        else if (op_to_add == MicroliteOperator_ETHOSU) {  
            status = tf_op_resolver->AddEthosU(); // custom
        }
        else if (op_to_add == MicroliteOperator_EXP) {  
            status = tf_op_resolver->AddExp(); 
        }
        else if (op_to_add == MicroliteOperator_EXPAND_DIMS) {  
            status = tf_op_resolver->AddExpandDims(); 
        }
        else if (op_to_add == MicroliteOperator_FILL) {  
            status = tf_op_resolver->AddFill(); 
        }
        else if (op_to_add == MicroliteOperator_FLOOR) {  
            status = tf_op_resolver->AddFloor(); 
        }
        else if (op_to_add == MicroliteOperator_FLOOR_DIV) {  
            status = tf_op_resolver->AddFloorDiv(); 
        }
        else if (op_to_add == MicroliteOperator_FLOOR_MOD) {  
            status = tf_op_resolver->AddFloorMod(); 
        } 
        else if (op_to_add == MicroliteOperator_FULLY_CONNECTED) {  
            // TODO This function can take a parameter.
            // need to come back and see how we could pass somethin custom to this function.

            //          TfLiteStatus AddFullyConnected(
            //       const TfLiteRegistration& registration = Register_FULLY_CONNECTED()) {
            //     return AddBuiltin(BuiltinOperator_FULLY_CONNECTED, registration,
            //                       ParseFullyConnected);
            //   }
            status = tf_op_resolver->AddFullyConnected(); 
        } 
        else if (op_to_add == MicroliteOperator_GATHER) {  
            status = tf_op_resolver->AddGather(); 
        } 
        else if (op_to_add == MicroliteOperator_GATHER_ND) {  
            status = tf_op_resolver->AddGatherNd(); 
        }  
        else if (op_to_add == MicroliteOperator_GREATER) {  
            status = tf_op_resolver->AddGreater(); 
        }   
        else if (op_to_add == MicroliteOperator_GREATER_EQUAL) {  
            status = tf_op_resolver->AddGreaterEqual(); 
        }    
        else if (op_to_add == MicroliteOperator_HARD_SWISH) {  
            status = tf_op_resolver->AddHardSwish(); 
        }   
        else if (op_to_add == MicroliteOperator_IF) {  
            status = tf_op_resolver->AddIf(); 
        }
        else if (op_to_add == MicroliteOperator_L2_NORMALIZATION) {  
            status = tf_op_resolver->AddL2Normalization(); 
        }
        else if (op_to_add == MicroliteOperator_L2_POOL_2D) {  
            status = tf_op_resolver->AddL2Pool2D(); 
        } 
        else if (op_to_add == MicroliteOperator_LEAKY_RELU) {  
            status = tf_op_resolver->AddLeakyRelu(); 
        } 
        else if (op_to_add == MicroliteOperator_LESS) {  
            status = tf_op_resolver->AddLess(); 
        } 
        else if (op_to_add == MicroliteOperator_LESS_EQUAL) {  
            status = tf_op_resolver->AddLessEqual(); 
        } 
        else if (op_to_add == MicroliteOperator_LOG) {  
            status = tf_op_resolver->AddLog(); 
        }
        else if (op_to_add == MicroliteOperator_LOGICAL_AND) {  
            status = tf_op_resolver->AddLogicalAnd(); 
        }
        else if (op_to_add == MicroliteOperator_LOGICAL_NOT) {  
            status = tf_op_resolver->AddLogicalNot(); 
        } 
        else if (op_to_add == MicroliteOperator_LOGICAL_OR) {  
            status = tf_op_resolver->AddLogicalOr(); 
        }
        else if (op_to_add == MicroliteOperator_LOGISTIC) {  
            status = tf_op_resolver->AddLogistic(); 
        } 
        else if (op_to_add == MicroliteOperator_MAXIMUM) {  
            status = tf_op_resolver->AddMaximum(); 
        }
        else if (op_to_add == MicroliteOperator_MAX_POOL_2D) {  
            status = tf_op_resolver->AddMaxPool2D(); 
        }
        else if (op_to_add == MicroliteOperator_MEAN) {  
            status = tf_op_resolver->AddMean(); 
        }
        else if (op_to_add == MicroliteOperator_MINIMUM) {  
            status = tf_op_resolver->AddMinimum(); 
        }
        else if (op_to_add == MicroliteOperator_MUL) {  
            status = tf_op_resolver->AddMul(); 
        }   
        else if (op_to_add == MicroliteOperator_NEG) {  
            status = tf_op_resolver->AddNeg(); 
        }
        else if (op_to_add == MicroliteOperator_NOT_EQUAL) {  
            status = tf_op_resolver->AddNotEqual(); 
        }
        else if (op_to_add == MicroliteOperator_PACK) {  
            status = tf_op_resolver->AddPack(); 
        }
        else if (op_to_add == MicroliteOperator_PAD) {  
            status = tf_op_resolver->AddPad(); 
        }
        else if (op_to_add == MicroliteOperator_PADV2) {  
            status = tf_op_resolver->AddPadV2(); 
        }
        else if (op_to_add == MicroliteOperator_PRELU) {  
            status = tf_op_resolver->AddPrelu(); 
        }
        else if (op_to_add == MicroliteOperator_QUANTIZE) {  
            status = tf_op_resolver->AddQuantize(); 
        }
        else if (op_to_add == MicroliteOperator_REDUCE_MAX) {  
            status = tf_op_resolver->AddReduceMax(); 
        }
        else if (op_to_add == MicroliteOperator_RELU) {  
            status = tf_op_resolver->AddRelu(); 
        }
        else if (op_to_add == MicroliteOperator_RELU6) {  
            status = tf_op_resolver->AddRelu6(); 
        }
        else if (op_to_add == MicroliteOperator_RESHAPE) {  
            status = tf_op_resolver->AddReshape(); 
        }
        else if (op_to_add == MicroliteOperator_RESIZE_BILINEAR) {  
            status = tf_op_resolver->AddResizeBilinear(); 
        }
        else if (op_to_add == MicroliteOperator_RESIZE_NEAREST_NEIGHBOR) {  
            status = tf_op_resolver->AddResizeNearestNeighbor(); 
        } 
        else if (op_to_add == MicroliteOperator_ROUND) {  
            status = tf_op_resolver->AddRound(); 
        } 
        else if (op_to_add == MicroliteOperator_RSQRT) {  
            status = tf_op_resolver->AddRsqrt(); 
        }
        else if (op_to_add == MicroliteOperator_SHAPE) {  
            status = tf_op_resolver->AddShape(); 
        }
        else if (op_to_add == MicroliteOperator_SIN) {  
            status = tf_op_resolver->AddSin(); 
        }
        else if (op_to_add == MicroliteOperator_SOFTMAX) {  
            status = tf_op_resolver->AddSoftmax(); // takes argument
        }
        else if (op_to_add == MicroliteOperator_SPACE_TO_BATCH_ND) {  
            status = tf_op_resolver->AddSpaceToBatchNd(); 
        }
        else if (op_to_add == MicroliteOperator_SPACE_TO_DEPTH) {  
            status = tf_op_resolver->AddSpaceToDepth(); 
        }
        else if (op_to_add == MicroliteOperator_SPLIT) {  
            status = tf_op_resolver->AddSplit(); 
        }
        else if (op_to_add == MicroliteOperator_SPLIT_V) {  
            status = tf_op_resolver->AddSplitV(); 
        }
        else if (op_to_add == MicroliteOperator_SQUEEZE) {  
            status = tf_op_resolver->AddSqueeze(); 
        }
        else if (op_to_add == MicroliteOperator_SQRT) {  
            status = tf_op_resolver->AddSqrt(); 
        }
        else if (op_to_add == MicroliteOperator_SQUARE) {  
            status = tf_op_resolver->AddSquare(); 
        }
        else if (op_to_add == MicroliteOperator_STRIDED_SLICE) {  
            status = tf_op_resolver->AddStridedSlice(); 
        }
        else if (op_to_add == MicroliteOperator_SUB) {  
            status = tf_op_resolver->AddSub(); 
        }
        else if (op_to_add == MicroliteOperator_SVDF) {  
            status = tf_op_resolver->AddSvdf(); 
        }
        else if (op_to_add == MicroliteOperator_TANH) {  
            status = tf_op_resolver->AddTanh(); 
        }
        else if (op_to_add == MicroliteOperator_TRANSPOSE_CONV) {  
            status = tf_op_resolver->AddTransposeConv(); 
        }
        else if (op_to_add == MicroliteOperator_TRANSPOSE) {  
            status = tf_op_resolver->AddTranspose(); 
        }
        else if (op_to_add == MicroliteOperator_UNPACK) {  
            status = tf_op_resolver->AddUnpack(); 
        }
        else if (op_to_add == MicroliteOperator_ZEROS_LIKE) {  
            status = tf_op_resolver->AddZerosLike(); 
        }

        if (status == kTfLiteOk) {
            return 0;
        }
        else {
            // TODO logout the actual status code
            return 1;
        }
    }


    int libtf_invoke(microlite_interpreter_obj_t *microlite_interpretor)
    {
        
        tflite::ErrorReporter *error_reporter = (tflite::ErrorReporter *)microlite_interpretor->tf_error_reporter;

        const tflite::Model *model = (const tflite::Model *)microlite_interpretor->tf_model;

        tflite::MicroOpResolver *resolver = (tflite::MicroOpResolver *)microlite_interpretor->op_resolver->tf_op_resolver;

        tflite::MicroInterpreter interpreter(model, 
                                             *resolver, 
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

//    int libtf_initialize_micro_features()
//    {
//        microlite::MicropythonErrorReporter micro_error_reporter;
//        tflite::ErrorReporter *error_reporter = &micro_error_reporter;
//
//        if (InitializeMicroFeatures(error_reporter) != kTfLiteOk) {
//            return 1;
//        }
//        return 0;
//    }
//
//    int libtf_generate_micro_features(const int16_t* input, int input_size,
//            int output_size, int8_t* output, size_t* num_samples_read)
//    {
//        microlite::MicropythonErrorReporter micro_error_reporter;
//        tflite::ErrorReporter *error_reporter = &micro_error_reporter;
//
//        if (GenerateMicroFeatures(error_reporter, input, input_size,
//                    output_size, output, num_samples_read) != kTfLiteOk) {
//            return 1;
//        }
//        return 0;
//    }
}
