set(IDF_TARGET esp32s2)
set(SDKCONFIG_DEFAULTS
    ${MICROPY_PORT_DIR}/boards/sdkconfig.base
    ${MICROPY_PORT_DIR}/boards/sdkconfig.spiram_sx
    # ${MICROPY_PORT_DIR}/boards/sdkconfig.usb
    ${MICROPY_BOARD_DIR}/sdkconfig.board
)

message (STATUS "mpconfigboard.cmake: PROJECT_DIR=${PROJECT_DIR}")

set(USER_C_MODULES
    ${PROJECT_DIR}/micropython-modules/micropython.cmake
)

if(NOT MICROPY_FROZEN_MANIFEST)
    set(MICROPY_FROZEN_MANIFEST ${MICROPY_PORT_DIR}/boards/manifest.py)
endif()
