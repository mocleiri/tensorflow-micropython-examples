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

static int setup = 0;

int libtf_op_resolver_init(void *op_resolver) {

if (setup)
    return 1;

tflite::MicroMutableOpResolver<MICROLITE_TOTAL_OPS> *tf_op_resolver = (tflite::MicroMutableOpResolver<MICROLITE_TOTAL_OPS> *)op_resolver;

static TfLiteStatus status;

#if MICROLITE_OP_ABS
status = tf_op_resolver->AddAbs();
#endif

#if MICROLITE_OP_ADD
status = tf_op_resolver->AddAdd();
#endif

#if MICROLITE_OP_ADD_N
status = tf_op_resolver->AddAddN();
#endif

#if MICROLITE_OP_ARG_MAX
status = tf_op_resolver->AddArgMax();
#endif

#if MICROLITE_OP_ARG_MIN
status = tf_op_resolver->AddArgMin();
#endif

#if MICROLITE_OP_AVERAGE_POOL_2D
status = tf_op_resolver->AddAveragePool2D();
#endif

#if MICROLITE_OP_BATCH_TO_SPACE_ND
status = tf_op_resolver->AddBatchToSpaceNd();
#endif

#if MICROLITE_OP_CAST
status = tf_op_resolver->AddCast();
#endif

#if MICROLITE_OP_CEIL
status = tf_op_resolver->AddCeil();
#endif

#if MICROLITE_OP_CIRCULAR_BUFFER
status = tf_op_resolver->AddCircularBuffer(); // custom
#endif

#if MICROLITE_OP_CONCATENATION
status = tf_op_resolver->AddConcatenation();
#endif

#if MICROLITE_OP_CONV_2D
status = tf_op_resolver->AddConv2D();
#endif

#if MICROLITE_OP_COS
status = tf_op_resolver->AddCos();
#endif

#if MICROLITE_OP_CUMSUM
status = tf_op_resolver->AddCumSum();
#endif

#if MICROLITE_OP_DEPTH_TO_SPACE
status = tf_op_resolver->AddDepthToSpace();
#endif

#if MICROLITE_OP_DEPTHWISE_CONV_2D
status = tf_op_resolver->AddDepthwiseConv2D();
#endif

#if MICROLITE_OP_DEQUANTIZE
status = tf_op_resolver->AddDequantize();
#endif

#if MICROLITE_OP_DETECTION_POSTPROCESS
status = tf_op_resolver->AddDetectionPostprocess();  // custom
#endif

#if MICROLITE_OP_ELU
status = tf_op_resolver->AddElu();
#endif

#if MICROLITE_OP_EQUAL
status = tf_op_resolver->AddEqual();
#endif

#if MICROLITE_OP_ETHOSU
status = tf_op_resolver->AddEthosU(); // custom
#endif

#if MICROLITE_OP_EXP
status = tf_op_resolver->AddExp();
#endif

#if MICROLITE_OP_EXPAND_DIMS
status = tf_op_resolver->AddExpandDims();
#endif

#if MICROLITE_OP_FILL
status = tf_op_resolver->AddFill();
#endif

#if MICROLITE_OP_FLOOR
status = tf_op_resolver->AddFloor();
#endif

#if MICROLITE_OP_FLOOR_DIV
status = tf_op_resolver->AddFloorDiv();
#endif

#if MICROLITE_OP_FLOOR_MOD
status = tf_op_resolver->AddFloorMod();
#endif

#if MICROLITE_OP_FULLY_CONNECTED
// TODO This function can take a parameter.
// need to come back and see how we could pass somethin custom to this function.

//          TfLiteStatus AddFullyConnected(
//       const TfLiteRegistration& registration = Register_FULLY_CONNECTED()
//     return AddBuiltin(BuiltinOperator_FULLY_CONNECTED, registration,
//                       ParseFullyConnected);
//   #endif
status = tf_op_resolver->AddFullyConnected();
#endif

#if MICROLITE_OP_GATHER
status = tf_op_resolver->AddGather();
#endif

#if MICROLITE_OP_GATHER_ND
status = tf_op_resolver->AddGatherNd();
#endif

#if MICROLITE_OP_GREATER
status = tf_op_resolver->AddGreater();
#endif

#if MICROLITE_OP_GREATER_EQUAL
status = tf_op_resolver->AddGreaterEqual();
#endif

#if MICROLITE_OP_HARD_SWISH
status = tf_op_resolver->AddHardSwish();
#endif

#if MICROLITE_OP_IF
status = tf_op_resolver->AddIf();
#endif

#if MICROLITE_OP_L2_NORMALIZATION
status = tf_op_resolver->AddL2Normalization();
#endif

#if MICROLITE_OP_L2_POOL_2D
status = tf_op_resolver->AddL2Pool2D();
#endif

#if MICROLITE_OP_LEAKY_RELU
status = tf_op_resolver->AddLeakyRelu();
#endif

#if MICROLITE_OP_LESS
status = tf_op_resolver->AddLess();
#endif

#if MICROLITE_OP_LESS_EQUAL
status = tf_op_resolver->AddLessEqual();
#endif

#if MICROLITE_OP_LOG
status = tf_op_resolver->AddLog();
#endif

#if MICROLITE_OP_LOGICAL_AND
status = tf_op_resolver->AddLogicalAnd();
#endif

#if MICROLITE_OP_LOGICAL_NOT
status = tf_op_resolver->AddLogicalNot();
#endif

#if MICROLITE_OP_LOGICAL_OR
status = tf_op_resolver->AddLogicalOr();
#endif

#if MICROLITE_OP_LOGISTIC
status = tf_op_resolver->AddLogistic();
#endif

#if MICROLITE_OP_MAXIMUM
status = tf_op_resolver->AddMaximum();
#endif

#if MICROLITE_OP_MAX_POOL_2D
status = tf_op_resolver->AddMaxPool2D();
#endif

#if MICROLITE_OP_MEAN
status = tf_op_resolver->AddMean();
#endif

#if MICROLITE_OP_MINIMUM
status = tf_op_resolver->AddMinimum();
#endif

#if MICROLITE_OP_MUL
status = tf_op_resolver->AddMul();
#endif

#if MICROLITE_OP_NEG
status = tf_op_resolver->AddNeg();
#endif

#if MICROLITE_OP_NOT_EQUAL
status = tf_op_resolver->AddNotEqual();
#endif

#if MICROLITE_OP_PACK
status = tf_op_resolver->AddPack();
#endif

#if MICROLITE_OP_PAD
status = tf_op_resolver->AddPad();
#endif

#if MICROLITE_OP_PADV2
status = tf_op_resolver->AddPadV2();
#endif

#if MICROLITE_OP_PRELU
status = tf_op_resolver->AddPrelu();
#endif

#if MICROLITE_OP_QUANTIZE
status = tf_op_resolver->AddQuantize();
#endif

#if MICROLITE_OP_REDUCE_MAX
status = tf_op_resolver->AddReduceMax();
#endif

#if MICROLITE_OP_RELU
status = tf_op_resolver->AddRelu();
#endif

#if MICROLITE_OP_RELU6
status = tf_op_resolver->AddRelu6();
#endif

#if MICROLITE_OP_RESHAPE
status = tf_op_resolver->AddReshape();
#endif

#if MICROLITE_OP_RESIZE_BILINEAR
status = tf_op_resolver->AddResizeBilinear();
#endif

#if MICROLITE_OP_RESIZE_NEAREST_NEIGHBOR
status = tf_op_resolver->AddResizeNearestNeighbor();
#endif

#if MICROLITE_OP_ROUND
status = tf_op_resolver->AddRound();
#endif

#if MICROLITE_OP_RSQRT
status = tf_op_resolver->AddRsqrt();
#endif

#if MICROLITE_OP_SHAPE
status = tf_op_resolver->AddShape();
#endif

#if MICROLITE_OP_SIN
status = tf_op_resolver->AddSin();
#endif

#if MICROLITE_OP_SOFTMAX
status = tf_op_resolver->AddSoftmax(); // takes argument
#endif

#if MICROLITE_OP_SPACE_TO_BATCH_ND
status = tf_op_resolver->AddSpaceToBatchNd();
#endif

#if MICROLITE_OP_SPACE_TO_DEPTH
status = tf_op_resolver->AddSpaceToDepth();
#endif

#if MICROLITE_OP_SPLIT
status = tf_op_resolver->AddSplit();
#endif

#if MICROLITE_OP_SPLIT_V
status = tf_op_resolver->AddSplitV();
#endif

#if MICROLITE_OP_SQUEEZE
status = tf_op_resolver->AddSqueeze();
#endif

#if MICROLITE_OP_SQRT
status = tf_op_resolver->AddSqrt();
#endif

#if MICROLITE_OP_SQUARE
status = tf_op_resolver->AddSquare();
#endif

#if MICROLITE_OP_STRIDED_SLICE
status = tf_op_resolver->AddStridedSlice();
#endif

#if MICROLITE_OP_SUB
status = tf_op_resolver->AddSub();
#endif

#if MICROLITE_OP_SVDF
status = tf_op_resolver->AddSvdf();
#endif

#if MICROLITE_OP_TANH
status = tf_op_resolver->AddTanh();
#endif

#if MICROLITE_OP_TRANSPOSE_CONV
status = tf_op_resolver->AddTransposeConv();
#endif

#if MICROLITE_OP_TRANSPOSE
status = tf_op_resolver->AddTranspose();
#endif

#if MICROLITE_OP_UNPACK
status = tf_op_resolver->AddUnpack();
#endif

#if MICROLITE_OP_ZEROS_LIKE
status = tf_op_resolver->AddZerosLike();

#endif

setup = 1;

return 0;

}



