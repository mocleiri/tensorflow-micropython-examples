set(SDKCONFIG_DEFAULTS
    boards/sdkconfig.base
    boards/sdkconfig.ble
    ../../../../boards/esp32/MICROLITE/sdkconfig.partition
)

if(MICROPY_BOARD_VARIANT STREQUAL "D2WD")
    set(SDKCONFIG_DEFAULTS
        ${SDKCONFIG_DEFAULTS}
        boards/ESP32_GENERIC/sdkconfig.d2wd
    )

    list(APPEND MICROPY_DEF_BOARD
        MICROPY_HW_MCU_NAME="ESP32-D2WD"
    )
endif()

if(MICROPY_BOARD_VARIANT STREQUAL "OTA")
    set(SDKCONFIG_DEFAULTS
        ${SDKCONFIG_DEFAULTS}
        boards/ESP32_GENERIC/sdkconfig.ota
    )

    list(APPEND MICROPY_DEF_BOARD
        MICROPY_HW_BOARD_NAME="Generic ESP32 module with OTA"
    )
endif()

if(MICROPY_BOARD_VARIANT STREQUAL "SPIRAM")
    set(SDKCONFIG_DEFAULTS
        ${SDKCONFIG_DEFAULTS}
        boards/sdkconfig.spiram
    )

    list(APPEND MICROPY_DEF_BOARD
        MICROPY_HW_BOARD_NAME="Generic ESP32 module with SPIRAM"
    )
endif()

if(MICROPY_BOARD_VARIANT STREQUAL "UNICORE")
    set(SDKCONFIG_DEFAULTS
        ${SDKCONFIG_DEFAULTS}
        boards/ESP32_GENERIC/sdkconfig.unicore
    )

    list(APPEND MICROPY_DEF_BOARD
        MICROPY_HW_MCU_NAME="ESP32-UNICORE"
    )
endif()


set(USER_C_MODULES
    ${CMAKE_CURRENT_LIST_DIR}/../../../micropython-modules/micropython.cmake
)

list(APPEND EXTRA_COMPONENT_DIRS ${CMAKE_CURRENT_LIST_DIR}/../../../dependencies/tflite-micro-esp-examples/components/esp-tflite-micro)