#ifndef HELLO_WORLD_MICRO_LITE_H_
#define HELLO_WORLD_MICRO_LITE_H_

#include "py/runtime.h"
#include "py/obj.h"
#include "py/objstr.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _microlite_interpreter_obj_t {
    mp_obj_base_t base;
    mp_obj_str_t *model_data;
    mp_obj_str_t *tensor_area;
} microlite_interpreter_obj_t;

#ifdef __cplusplus
}
#endif

#endif
