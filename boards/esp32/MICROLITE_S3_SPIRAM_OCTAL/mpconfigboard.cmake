set(IDF_TARGET esp32s3)

set(SDKCONFIG_DEFAULTS

    ${MICROPY_PORT_DIR}/boards/sdkconfig.base
    ${MICROPY_PORT_DIR}/boards/sdkconfig.ble
    ${MICROPY_PORT_DIR}/boards/sdkconfig.spiram_sx
    ${MICROPY_PORT_DIR}/boards/sdkconfig.spiram_oct
    ${MICROPY_PORT_DIR}/boards/sdkconfig.240mhz
    ${MICROPY_BOARD_DIR}/sdkconfig.board
    ${MICROPY_BOARD_DIR}/sdkconfig-8m.partition
)

message (STATUS "mpconfigboard.cmake: PROJECT_DIR=${PROJECT_DIR}")

set(USER_C_MODULES
    ${PROJECT_DIR}/micropython-modules/micropython.cmake
)
