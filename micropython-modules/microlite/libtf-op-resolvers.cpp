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


#include "libtf-op-resolvers.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/kernels/micro_ops.h"

static int setup = 0;

// static TfLiteRegistration dummyRegistration;

// #if MICROLITE_OP_ADD == 0
// TfLiteRegistration tflite::Register_ADD() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_ADD_N == 0
// TfLiteRegistration tflite::Register_ADD_N() {
//     return dummyRegistration;
// }
// #endif

// // Register_ASSIGN_VARIABLE() {
// //     return dummyRegistration;
// // }
    
// #if MICROLITE_OP_AVERAGE_POOL_2D == 0
// TfLiteRegistration tflite::Register_AVERAGE_POOL_2D() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_BATCH_TO_SPACE_ND == 0
// TfLiteRegistration tflite::Register_BATCH_TO_SPACE_ND() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_CAST == 0
// TfLiteRegistration tflite::Register_CAST() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_CIRCULAR_BUFFER == 0
// TfLiteRegistration tflite::Register_CIRCULAR_BUFFER() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_CUMSUM == 0
// TfLiteRegistration tflite::Register_CUMSUM() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_DEPTH_TO_SPACE == 0
// TfLiteRegistration tflite::Register_DEPTH_TO_SPACE() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_DEPTHWISE_CONV_2D == 0
// TfLiteRegistration tflite::Register_DEPTHWISE_CONV_2D() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_ELU == 0
// TfLiteRegistration tflite::Register_ELU() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_EXP == 0
// TfLiteRegistration tflite::Register_EXP() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_EXPAND_DIMS == 0
// TfLiteRegistration tflite::Register_EXPAND_DIMS() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_FILL == 0
// TfLiteRegistration tflite::Register_FILL() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_FLOOR_DIV == 0
// TfLiteRegistration tflite::Register_FLOOR_DIV() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_FLOOR_MOD == 0
// TfLiteRegistration tflite::Register_FLOOR_MOD() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_GATHER == 0
// TfLiteRegistration tflite::Register_GATHER() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_GATHER_ND == 0
// TfLiteRegistration tflite::Register_GATHER_ND() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_HARD_SWISH == 0
// TfLiteRegistration tflite::Register_HARD_SWISH() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_IF == 0
// TfLiteRegistration tflite::Register_IF() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_L2_POOL_2D == 0
// TfLiteRegistration tflite::Register_L2_POOL_2D() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_LEAKY_RELU == 0
// TfLiteRegistration tflite::Register_LEAKY_RELU() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_LOGICAL_AND == 0
// TfLiteRegistration tflite::Register_LOGICAL_AND() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_LOGICAL_OR == 0
// TfLiteRegistration tflite::Register_LOGICAL_OR() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_LOGISTIC == 0
// TfLiteRegistration tflite::Register_LOGISTIC() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_MAX_POOL_2D == 0
// TfLiteRegistration tflite::Register_MAX_POOL_2D() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_MUL == 0
// TfLiteRegistration tflite::Register_MUL() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_QUANTIZE == 0
// TfLiteRegistration tflite::Register_QUANTIZE() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_RELU == 0
// TfLiteRegistration tflite::Register_RELU() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_RELU6 == 0
// TfLiteRegistration tflite::Register_RELU6() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_RESIZE_BILINEAR == 0
// TfLiteRegistration tflite::Register_RESIZE_BILINEAR() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_SHAPE == 0
// TfLiteRegistration tflite::Register_SHAPE() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_SPACE_TO_BATCH_ND == 0
// TfLiteRegistration tflite::Register_SPACE_TO_BATCH_ND() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_SPACE_TO_DEPTH == 0
// TfLiteRegistration tflite::Register_SPACE_TO_DEPTH() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_SQUEEZE == 0
// TfLiteRegistration tflite::Register_SQUEEZE() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_SUB == 0
// TfLiteRegistration tflite::Register_SUB() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_SVDF == 0
// TfLiteRegistration tflite::Register_SVDF() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_TRANSPOSE == 0
// TfLiteRegistration tflite::Register_TRANSPOSE() {
//     return dummyRegistration;
// }
// #endif
// #if MICROLITE_OP_ZEROS_LIKE == 0
// TfLiteRegistration tflite::Register_ZEROS_LIKE() {
//     return dummyRegistration;
// }
// #endif

//     // namespace ops {
// // namespace micro {

//     // tflite :: ops :: micro namespace
// #if MICROLITE_OP_ABS == 0
// TfLiteRegistration tflite::ops::micro::Register_ABS() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_ARG_MAX == 0
// TfLiteRegistration tflite::ops::micro::Register_ARG_MAX() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_ARG_MIN == 0
// TfLiteRegistration tflite::ops::micro::Register_ARG_MIN() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_CEIL == 0
// TfLiteRegistration tflite::ops::micro::Register_CEIL() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_CONCATENATION == 0
// TfLiteRegistration tflite::ops::micro::Register_CONCATENATION() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_CONV_2D == 0
// // comes in through conv
// // TODO
// #endif

// #if MICROLITE_OP_COS == 0
// TfLiteRegistration tflite::ops::micro::Register_COS() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_DEQUANTIZE == 0
// TfLiteRegistration tflite::ops::micro::Register_DEQUANTIZE() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_DETECTION_POSTPROCESS == 0
// // TODO: find out if there is an register
// // Register_ADD_N() {
// //     return dummyRegistration;
// // }
// #endif



// #if MICROLITE_OP_EQUAL == 0
// TfLiteRegistration tflite::ops::micro::Register_EQUAL() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_ETHOSU == 0
// // TODO find registration
// // Register_ADD_N() {
// //     return dummyRegistration;
// // }
// #endif

// #if MICROLITE_OP_FLOOR == 0
// TfLiteRegistration tflite::ops::micro::Register_FLOOR() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_FULLY_CONNECTED == 0

// // TODO This function can take a parameter.
// // need to come back and see how we could pass somethin custom to this function.

// //          TfLiteStatus AddFullyConnected(
// //       const TfLiteRegistration& registration = Register_FULLY_CONNECTED()
// //     return AddBuiltin(BuiltinOperator_FULLY_CONNECTED, registration,
// //                       ParseFullyConnected);
// //   #endif
// #endif


// #if MICROLITE_OP_GREATER == 0
// TfLiteRegistration tflite::ops::micro::Register_GREATER() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_GREATER_EQUAL == 0
// TfLiteRegistration tflite::ops::micro::Register_GREATER_EQUAL() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_L2_NORMALIZATION == 0
// // TODO
// #endif



// #if MICROLITE_OP_LESS == 0
// TfLiteRegistration tflite::ops::micro::Register_LESS() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_LESS_EQUAL == 0
// TfLiteRegistration tflite::ops::micro::Register_LESS_EQUAL() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_LOG == 0
// TfLiteRegistration tflite::ops::micro::Register_LOG() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_LOGICAL_NOT == 0
// TfLiteRegistration tflite::ops::micro::Register_LOGICAL_NOT() {
//     return dummyRegistration;
// }
// #endif



// #if MICROLITE_OP_MAXIMUM == 0
// TfLiteRegistration tflite::ops::micro::Register_MAXIMUM() {
//     return dummyRegistration;
// }
// #endif



// #if MICROLITE_OP_MEAN == 0
// TfLiteRegistration tflite::ops::micro::Register_MEAN() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_MINIMUM == 0
// TfLiteRegistration tflite::ops::micro::Register_MINIMUM() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_NEG == 0
// TfLiteRegistration tflite::ops::micro::Register_NEG() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_NOT_EQUAL == 0
// TfLiteRegistration tflite::ops::micro::Register_NOT_EQUAL() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_PACK == 0
// TfLiteRegistration tflite::ops::micro::Register_PACK() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_PAD == 0
// TfLiteRegistration tflite::ops::micro::Register_PAD() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_PADV2 == 0
// TfLiteRegistration tflite::ops::micro::Register_PADV2() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_PRELU == 0
// TfLiteRegistration tflite::ops::micro::Register_PRELU() {
//     return dummyRegistration;
// }
// #endif



// #if MICROLITE_OP_REDUCE_MAX == 0
// TfLiteRegistration tflite::ops::micro::Register_REDUCE_MAX() {
//     return dummyRegistration;
// }
// #endif



// #if MICROLITE_OP_RESHAPE == 0
// TfLiteRegistration tflite::ops::micro::Register_RESHAPE() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_RESIZE_NEAREST_NEIGHBOR == 0
// TfLiteRegistration tflite::ops::micro::Register_RESIZE_NEAREST_NEIGHBOR() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_ROUND == 0
// TfLiteRegistration tflite::ops::micro::Register_ROUND() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_RSQRT == 0
// TfLiteRegistration tflite::ops::micro::Register_RSQRT() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_SIN == 0
// TfLiteRegistration tflite::ops::micro::Register_SIN() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_SOFTMAX == 0
// // TODO
// #endif


// #if MICROLITE_OP_SPLIT == 0
// TfLiteRegistration tflite::ops::micro::Register_SPLIT() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_SPLIT_V == 0
// TfLiteRegistration tflite::ops::micro::Register_SPLIT_V() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_SQRT == 0
// TfLiteRegistration tflite::ops::micro::Register_SQRT() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_SQUARE == 0
// TfLiteRegistration tflite::ops::micro::Register_SQUARE() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_STRIDED_SLICE == 0

// TfLiteRegistration tflite::ops::micro::Register_STRIDED_SLICE() {
//     return dummyRegistration;
// }
// #endif


// #if MICROLITE_OP_TANH == 0
// TfLiteRegistration tflite::ops::micro::Register_TANH() {
//     return dummyRegistration;
// }
// #endif

// #if MICROLITE_OP_TRANSPOSE_CONV == 0
// // TODO
// #endif

// #if MICROLITE_OP_UNPACK == 0
// TfLiteRegistration tflite::ops::micro::Register_UNPACK() {
//     return dummyRegistration;
// }
// #endif

int libtf_op_resolver_init(void *op_resolver) {

if (setup)
    return 1;

tflite::MicroMutableOpResolver<MICROLITE_TOTAL_OPS> *tf_op_resolver = (tflite::MicroMutableOpResolver<MICROLITE_TOTAL_OPS> *)op_resolver;

static TfLiteStatus status;
int abs_op = MICROLITE_OP_ABS;
int add_op = MICROLITE_OP_ADD;

#if MICROLITE_OP_ABS == 1
status = tf_op_resolver->AddAbs();
#endif

#if MICROLITE_OP_ADD == 1
status = tf_op_resolver->AddAdd();
#endif

#if MICROLITE_OP_ADD_N == 1
status = tf_op_resolver->AddAddN();
#endif

#if MICROLITE_OP_ARG_MAX == 1
status = tf_op_resolver->AddArgMax();
#endif

#if MICROLITE_OP_ARG_MIN == 1
status = tf_op_resolver->AddArgMin();
#endif

#if MICROLITE_OP_AVERAGE_POOL_2D == 1
status = tf_op_resolver->AddAveragePool2D();
#endif

#if MICROLITE_OP_BATCH_TO_SPACE_ND == 1
status = tf_op_resolver->AddBatchToSpaceNd();
#endif

#if MICROLITE_OP_CAST == 1
status = tf_op_resolver->AddCast();
#endif

#if MICROLITE_OP_CEIL == 1
status = tf_op_resolver->AddCeil();
#endif

#if MICROLITE_OP_CIRCULAR_BUFFER == 1
status = tf_op_resolver->AddCircularBuffer(); // custom
#endif

#if MICROLITE_OP_CONCATENATION == 1
status = tf_op_resolver->AddConcatenation();
#endif

#if MICROLITE_OP_CONV_2D == 1
status = tf_op_resolver->AddConv2D();
#endif

#if MICROLITE_OP_COS == 1
status = tf_op_resolver->AddCos();
#endif

#if MICROLITE_OP_CUMSUM == 1
status = tf_op_resolver->AddCumSum();
#endif

#if MICROLITE_OP_DEPTH_TO_SPACE == 1
status = tf_op_resolver->AddDepthToSpace();
#endif

#if MICROLITE_OP_DEPTHWISE_CONV_2D == 1
status = tf_op_resolver->AddDepthwiseConv2D();
#endif

#if MICROLITE_OP_DEQUANTIZE == 1
status = tf_op_resolver->AddDequantize();
#endif

#if MICROLITE_OP_DETECTION_POSTPROCESS == 1
status = tf_op_resolver->AddDetectionPostprocess();  // custom
#endif

#if MICROLITE_OP_ELU == 1
status = tf_op_resolver->AddElu();
#endif

#if MICROLITE_OP_EQUAL == 1
status = tf_op_resolver->AddEqual();
#endif

#if MICROLITE_OP_ETHOSU == 1
status = tf_op_resolver->AddEthosU(); // custom
#endif

#if MICROLITE_OP_EXP == 1
status = tf_op_resolver->AddExp();
#endif

#if MICROLITE_OP_EXPAND_DIMS == 1
status = tf_op_resolver->AddExpandDims();
#endif

#if MICROLITE_OP_FILL == 1
status = tf_op_resolver->AddFill();
#endif

#if MICROLITE_OP_FLOOR == 1
status = tf_op_resolver->AddFloor();
#endif

#if MICROLITE_OP_FLOOR_DIV == 1
status = tf_op_resolver->AddFloorDiv();
#endif

#if MICROLITE_OP_FLOOR_MOD == 1
status = tf_op_resolver->AddFloorMod();
#endif

#if MICROLITE_OP_FULLY_CONNECTED == 1
// TODO This function can take a parameter.
// need to come back and see how we could pass somethin custom to this function.

//          TfLiteStatus AddFullyConnected(
//       const TfLiteRegistration& registration = Register_FULLY_CONNECTED()
//     return AddBuiltin(BuiltinOperator_FULLY_CONNECTED, registration,
//                       ParseFullyConnected);
//   #endif
status = tf_op_resolver->AddFullyConnected();
#endif

#if MICROLITE_OP_GATHER == 1
status = tf_op_resolver->AddGather();
#endif

#if MICROLITE_OP_GATHER_ND == 1
status = tf_op_resolver->AddGatherNd();
#endif

#if MICROLITE_OP_GREATER == 1
status = tf_op_resolver->AddGreater();
#endif

#if MICROLITE_OP_GREATER_EQUAL == 1
status = tf_op_resolver->AddGreaterEqual();
#endif

#if MICROLITE_OP_HARD_SWISH == 1
status = tf_op_resolver->AddHardSwish();
#endif

#if MICROLITE_OP_IF == 1
status = tf_op_resolver->AddIf();
#endif

#if MICROLITE_OP_L2_NORMALIZATION == 1
status = tf_op_resolver->AddL2Normalization();
#endif

#if MICROLITE_OP_L2_POOL_2D == 1
status = tf_op_resolver->AddL2Pool2D();
#endif

#if MICROLITE_OP_LEAKY_RELU == 1
status = tf_op_resolver->AddLeakyRelu();
#endif

#if MICROLITE_OP_LESS == 1
status = tf_op_resolver->AddLess();
#endif

#if MICROLITE_OP_LESS_EQUAL == 1
status = tf_op_resolver->AddLessEqual();
#endif

#if MICROLITE_OP_LOG == 1
status = tf_op_resolver->AddLog();
#endif

#if MICROLITE_OP_LOGICAL_AND == 1
status = tf_op_resolver->AddLogicalAnd();
#endif

#if MICROLITE_OP_LOGICAL_NOT == 1
status = tf_op_resolver->AddLogicalNot();
#endif

#if MICROLITE_OP_LOGICAL_OR == 1
status = tf_op_resolver->AddLogicalOr();
#endif

#if MICROLITE_OP_LOGISTIC == 1
status = tf_op_resolver->AddLogistic();
#endif

#if MICROLITE_OP_MAXIMUM == 1
status = tf_op_resolver->AddMaximum();
#endif

#if MICROLITE_OP_MAX_POOL_2D == 1
status = tf_op_resolver->AddMaxPool2D();
#endif

#if MICROLITE_OP_MEAN == 1
status = tf_op_resolver->AddMean();
#endif

#if MICROLITE_OP_MINIMUM == 1
status = tf_op_resolver->AddMinimum();
#endif

#if MICROLITE_OP_MUL == 1
status = tf_op_resolver->AddMul();
#endif

#if MICROLITE_OP_NEG == 1
status = tf_op_resolver->AddNeg();
#endif

#if MICROLITE_OP_NOT_EQUAL == 1
status = tf_op_resolver->AddNotEqual();
#endif

#if MICROLITE_OP_PACK == 1
status = tf_op_resolver->AddPack();
#endif

#if MICROLITE_OP_PAD == 1
status = tf_op_resolver->AddPad();
#endif

#if MICROLITE_OP_PADV2 == 1
status = tf_op_resolver->AddPadV2();
#endif

#if MICROLITE_OP_PRELU == 1
status = tf_op_resolver->AddPrelu();
#endif

#if MICROLITE_OP_QUANTIZE == 1
status = tf_op_resolver->AddQuantize();
#endif

#if MICROLITE_OP_REDUCE_MAX == 1
status = tf_op_resolver->AddReduceMax();
#endif

#if MICROLITE_OP_RELU == 1
status = tf_op_resolver->AddRelu();
#endif

#if MICROLITE_OP_RELU6 == 1
status = tf_op_resolver->AddRelu6();
#endif

#if MICROLITE_OP_RESHAPE == 1
status = tf_op_resolver->AddReshape();
#endif

#if MICROLITE_OP_RESIZE_BILINEAR == 1
status = tf_op_resolver->AddResizeBilinear();
#endif

#if MICROLITE_OP_RESIZE_NEAREST_NEIGHBOR == 1
status = tf_op_resolver->AddResizeNearestNeighbor();
#endif

#if MICROLITE_OP_ROUND == 1
status = tf_op_resolver->AddRound();
#endif

#if MICROLITE_OP_RSQRT == 1
status = tf_op_resolver->AddRsqrt();
#endif

#if MICROLITE_OP_SHAPE == 1
status = tf_op_resolver->AddShape();
#endif

#if MICROLITE_OP_SIN == 1
status = tf_op_resolver->AddSin();
#endif

#if MICROLITE_OP_SOFTMAX == 1
status = tf_op_resolver->AddSoftmax(); // takes argument
#endif

#if MICROLITE_OP_SPACE_TO_BATCH_ND == 1
status = tf_op_resolver->AddSpaceToBatchNd();
#endif

#if MICROLITE_OP_SPACE_TO_DEPTH == 1
status = tf_op_resolver->AddSpaceToDepth();
#endif

#if MICROLITE_OP_SPLIT == 1
status = tf_op_resolver->AddSplit();
#endif

#if MICROLITE_OP_SPLIT_V == 1
status = tf_op_resolver->AddSplitV();
#endif

#if MICROLITE_OP_SQUEEZE == 1
status = tf_op_resolver->AddSqueeze();
#endif

#if MICROLITE_OP_SQRT == 1
status = tf_op_resolver->AddSqrt();
#endif

#if MICROLITE_OP_SQUARE == 1
status = tf_op_resolver->AddSquare();
#endif

#if MICROLITE_OP_STRIDED_SLICE == 1
status = tf_op_resolver->AddStridedSlice();
#endif

#if MICROLITE_OP_SUB == 1
status = tf_op_resolver->AddSub();
#endif

#if MICROLITE_OP_SVDF == 1
status = tf_op_resolver->AddSvdf();
#endif

#if MICROLITE_OP_TANH == 1
status = tf_op_resolver->AddTanh();
#endif

#if MICROLITE_OP_TRANSPOSE_CONV == 1
status = tf_op_resolver->AddTransposeConv();
#endif

#if MICROLITE_OP_TRANSPOSE == 1
status = tf_op_resolver->AddTranspose();
#endif

#if MICROLITE_OP_UNPACK == 1
status = tf_op_resolver->AddUnpack();
#endif

#if MICROLITE_OP_ZEROS_LIKE == 1
status = tf_op_resolver->AddZerosLike();

#endif


setup = 1;

return status;
}


// }
// }
// }


