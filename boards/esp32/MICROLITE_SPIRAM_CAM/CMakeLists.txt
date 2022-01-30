# Top-level cmake file for building MicroPython on ESP32.
# Nothing in here needs to be customised, it will work for any board.

cmake_minimum_required(VERSION 3.12)

# Set the location of MicroPython, the esp32 port, and the board directory.
get_filename_component(PROJECT_DIR "../../.." ABSOLUTE)
set(MICROPY_PORT_DIR ${PROJECT_DIR}/micropython/ports/esp32)
get_filename_component(MICROPY_BOARD_DIR "." ABSOLUTE)

set(EXTRA_COMPONENT_DIRS ../../../tflm_esp_kernels/examples/person_detection/esp32-camera)

message (STATUS "EXTRA_COMPONENT_DIRS=${EXTRA_COMPONENT_DIRS}")
message (STATUS "PROJECT_DIR=${PROJECT_DIR}")
message (STATUS "MICROPY_PORT_DIR=${MICROPY_PORT_DIR}")
message (STATUS "MICROPY_BOARD_DIR=${MICROPY_BOARD_DIR}")

# Define the output sdkconfig so it goes in the build directory.
set(SDKCONFIG ${CMAKE_BINARY_DIR}/sdkconfig)

# Include board config; this is expected to set SDKCONFIG_DEFAULTS (among other options).
include(${MICROPY_BOARD_DIR}/mpconfigboard.cmake)

# Concatenate all sdkconfig files into a combined one for the IDF to use.
file(WRITE ${CMAKE_BINARY_DIR}/sdkconfig.combined.in "")
foreach(SDKCONFIG_DEFAULT ${SDKCONFIG_DEFAULTS})
    file(READ ${SDKCONFIG_DEFAULT} CONTENTS)
    file(APPEND ${CMAKE_BINARY_DIR}/sdkconfig.combined.in "${CONTENTS}")
endforeach()
configure_file(${CMAKE_BINARY_DIR}/sdkconfig.combined.in ${CMAKE_BINARY_DIR}/sdkconfig.combined COPYONLY)
set(SDKCONFIG_DEFAULTS ${CMAKE_BINARY_DIR}/sdkconfig.combined)

# Include main IDF cmake file and define the project.
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(micropython)