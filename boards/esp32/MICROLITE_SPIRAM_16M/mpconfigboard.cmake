set(SDKCONFIG_DEFAULTS
    ${MICROPY_PORT_DIR}/boards/sdkconfig.base
    ${MICROPY_PORT_DIR}/boards/sdkconfig.ble
    ${MICROPY_PORT_DIR}/boards/sdkconfig.240mhz
    ${MICROPY_PORT_DIR}/boards/sdkconfig.spiram
    ${MICROPY_BOARD_DIR}/sdkconfig.16m
    ${MICROPY_BOARD_DIR}/sdkconfig-16m.partition

)
if(NOT MICROPY_FROZEN_MANIFEST)
    set(MICROPY_FROZEN_MANIFEST ${MICROPY_PORT_DIR}/boards/manifest.py)
endif()
