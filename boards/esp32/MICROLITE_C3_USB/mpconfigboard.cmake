set(IDF_TARGET esp32c3)

set(SDKCONFIG_DEFAULTS
    ${MICROPY_PORT_DIR}/boards/sdkconfig.base
    ${MICROPY_PORT_DIR}/boards/sdkconfig.ble
    ${MICROPY_PORT_DIR}/boards/GENERIC_C3_USB/sdkconfig.board
)

set(USER_C_MODULES
    ${PROJECT_DIR}/micropython-modules/micropython.cmake
)
