#ifndef HELLO_WORLD_MICRO_LITE_H_
#define HELLO_WORLD_MICRO_LITE_H_

#include "py/runtime.h"

#ifdef __cplusplus
extern "C"
#endif
mp_obj_t setup();

#ifdef __cplusplus
extern "C"
#endif
mp_obj_t execute();

#endif
