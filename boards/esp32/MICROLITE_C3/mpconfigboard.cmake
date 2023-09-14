set(IDF_TARGET esp32c3)

set(SDKCONFIG_DEFAULTS
    boards/sdkconfig.base
    boards/sdkconfig.ble
    boards/ESP32_GENERIC_C3/sdkconfig.c3usb
    ../../../../boards/esp32/MICROLITE_C3/sdkconfig.partition
)

set(USER_C_MODULES
    ${CMAKE_CURRENT_LIST_DIR}/../../../micropython-modules/micropython.cmake
)

list(APPEND EXTRA_COMPONENT_DIRS ${CMAKE_CURRENT_LIST_DIR}/../../../dependencies/tflite-micro-esp-examples/components/esp-tflite-micro)
