# Include MicroPython ESP32 component.

get_filename_component(CURRENT_DIR "." ABSOLUTE)

message(STATUS "microlite/main/cmake: CURRENT_DIR=${CURRENT_DIR}")

get_filename_component(MICROPY_DIR "../../../../micropython" ABSOLUTE)


message (STATUS "microlite/main/cmake: MICROPY_DIR=${MICROPY_DIR}")

set(PROJECT_DIR ${MICROPY_DIR}/ports/esp32)
include(${PROJECT_DIR}/main/CMakeLists.txt)