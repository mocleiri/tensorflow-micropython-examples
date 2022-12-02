set(IDF_TARGET esp32c3)

set(SDKCONFIG_DEFAULTS
    boards/sdkconfig.base
    boards/sdkconfig.ble
    boards/GENERIC_C3_USB/sdkconfig.board
)

set(USER_C_MODULES
    ${PROJECT_DIR}/micropython-modules/micropython.cmake
)
