# File to contain all the source list for Espressif boards to build

if(IDF_TARGET STREQUAL "esp32")
  set(MICROLITE_PLATFORM "ESP32")
endif()

if(IDF_TARGET STREQUAL "esp32s2")
  set(MICROLITE_PLATFORM "ESP32S2")
endif()

if(IDF_TARGET STREQUAL "esp32s3")
  set(MICROLITE_PLATFORM "ESP32S3")
endif()

if(IDF_TARGET STREQUAL "esp32c3")
  set(MICROLITE_PLATFORM "ESP32C3")
endif()

if (MICROLITE_PLATFORM STREQUAL "ESP32" OR
    MICROLITE_PLATFORM STREQUAL "ESP32S3" OR
    MICROLITE_PLATFORM STREQUAL "ESP32C3" OR
    MICROLITE_PLATFORM STREQUAL "ESP32S2")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++")
    set(ESP_NN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tflm_esp_kernels/components/esp-nn")
    set(ESP_NN_SRCS
        "${ESP_NN_DIR}/src/activation_functions/esp_nn_relu_ansi.c"
        "${ESP_NN_DIR}/src/basic_math/esp_nn_add_ansi.c"
        "${ESP_NN_DIR}/src/basic_math/esp_nn_mul_ansi.c"
        "${ESP_NN_DIR}/src/convolution/esp_nn_conv_ansi.c"
        "${ESP_NN_DIR}/src/convolution/esp_nn_conv_opt.c"
        "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_ansi.c"
        "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_opt.c"
        "${ESP_NN_DIR}/src/fully_connected/esp_nn_fully_connected_ansi.c"
        "${ESP_NN_DIR}/src/softmax/esp_nn_softmax_ansi.c"
        "${ESP_NN_DIR}/src/softmax/esp_nn_softmax_opt.c"
        "${ESP_NN_DIR}/src/pooling/esp_nn_avg_pool_ansi.c"
        "${ESP_NN_DIR}/src/pooling/esp_nn_max_pool_ansi.c"
    )
    if(CONFIG_IDF_TARGET_ESP32S3)
        list(APPEND ESP_NN_SRCS
            "${ESP_NN_DIR}/src/common/esp_nn_common_functions_esp32s3.S"
            "${ESP_NN_DIR}/src/common/esp_nn_multiply_by_quantized_mult_esp32s3.S"
            "${ESP_NN_DIR}/src/common/esp_nn_multiply_by_quantized_mult_ver1_esp32s3.S"
            "${ESP_NN_DIR}/src/activation_functions/esp_nn_relu_s8_esp32s3.S"
            "${ESP_NN_DIR}/src/basic_math/esp_nn_add_s8_esp32s3.S"
            "${ESP_NN_DIR}/src/basic_math/esp_nn_mul_s8_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_conv_esp32s3.c"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s8_esp32s3.c"
            "${ESP_NN_DIR}/src/convolution/esp_nn_conv_s16_mult8_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_conv_s8_mult8_1x1_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_conv_s16_mult4_1x1_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_conv_s8_filter_aligned_input_padded_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s8_mult1_3x3_padded_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s16_mult1_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s16_mult1_3x3_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s16_mult1_3x3_no_pad_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s16_mult8_3x3_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s16_mult4_esp32s3.S"
            "${ESP_NN_DIR}/src/convolution/esp_nn_depthwise_conv_s16_mult8_esp32s3.S"
            "${ESP_NN_DIR}/src/fully_connected/esp_nn_fully_connected_s8_esp32s3.S"
            "${ESP_NN_DIR}/src/pooling/esp_nn_max_pool_s8_esp32s3.S"
            "${ESP_NN_DIR}/src/pooling/esp_nn_avg_pool_s8_esp32s3.S")
    endif()
    set(ESP_NN_INC ${ESP_NN_DIR}/include ${ESP_NN_DIR}/src/common)
endif()
