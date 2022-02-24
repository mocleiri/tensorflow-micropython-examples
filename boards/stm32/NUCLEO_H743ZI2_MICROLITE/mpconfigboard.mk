include boards/NUCLEO_H743ZI/mpconfigboard.mk

USER_C_MODULES=../../../micropython-modules

# when enabled this flag blows up the firware size and it won't fit
# its a bit counter intuitive but keep this disabled to be able to git microlite into
# flash
MICROPY_ROM_TEXT_COMPRESSION = 0



