// This configuration is for a generic ESP32C3 board with 4MiB (or more) of flash.

#define MICROPY_HW_BOARD_NAME               "ESP32C3 module (microlite)"
#define MICROPY_HW_MCU_NAME                 "ESP32C3"

#define MICROPY_HW_ENABLE_SDCARD            (0)
#define MICROPY_PY_MACHINE_DAC              (0)
// TODO: early esp-idf's didn't support i2s.  check if this still applies
#define MICROPY_PY_MACHINE_I2S              (0)
