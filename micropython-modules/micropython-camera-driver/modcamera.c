/*
 * Copyright [2021] Mauro Riva <info@lemariva.com>
 * added get functions [2022] Uli Raich <uli.raich@gmail.com]
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <string.h>
#include "py/nlr.h"
#include "py/obj.h"
#include "modcamera.h"
#include "py/runtime.h"
#include "py/binary.h"

#if MICROPY_PY_CAMERA

#include "esp_system.h"
#include "esp_spi_flash.h"
#include "esp_camera.h"
#include "esp_log.h"

typedef struct _camera_obj_t {
    int8_t                 id;
    camera_config_t        config;
    bool                   used;
} camera_obj_t;

//STATIC camera_obj_t camera_obj;


STATIC bool camera_init_helper(camera_obj_t *camera, size_t n_pos_args, const mp_obj_t *pos_args, mp_map_t *kw_args) {
      enum {
        ARG_format,
        ARG_framesize,
        ARG_quality,
        ARG_d0,
        ARG_d1,
        ARG_d2,
        ARG_d3,
        ARG_d4,
        ARG_d5,
        ARG_d6,
        ARG_d7,
        ARG_VSYNC,
        ARG_HREF,
        ARG_PCLK,
        ARG_PWDN,
        ARG_RESET,
        ARG_XCLK,
        ARG_SIOD,
        ARG_SIOC,
        ARG_FREQ,
    };

    //{ MP_QSTR_d0,              MP_ARG_KW_ONLY                   | MP_ARG_OBJ,   {.u_obj = MP_OBJ_NULL} },
    static const mp_arg_t allowed_args[] = {
        { MP_QSTR_format,          MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = PIXFORMAT_JPEG} },
        { MP_QSTR_framesize,       MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = FRAMESIZE_UXGA} },
        { MP_QSTR_quality,         MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = 12} },
        { MP_QSTR_d0,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D0} },
        { MP_QSTR_d1,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D1} },
        { MP_QSTR_d2,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D2} },
        { MP_QSTR_d3,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D3} },
        { MP_QSTR_d4,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D4} },
        { MP_QSTR_d5,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D5} },
        { MP_QSTR_d6,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D6} },
        { MP_QSTR_d7,              MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_D7} },
        { MP_QSTR_vsync,           MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_VSYNC} },
        { MP_QSTR_href,            MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_HREF} },
        { MP_QSTR_pclk,            MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_PCLK} },
        { MP_QSTR_pwdn,            MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_PWDN} },
        { MP_QSTR_reset,           MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_RESET} },
        { MP_QSTR_xclk,            MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_XCLK} },
        { MP_QSTR_siod,            MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_SIOD} },
        { MP_QSTR_sioc,            MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = CAM_PIN_SIOC} },
        { MP_QSTR_xclk_freq,       MP_ARG_KW_ONLY  | MP_ARG_INT,   {.u_int = XCLK_FREQ_10MHz} },
    };

    mp_arg_val_t args[MP_ARRAY_SIZE(allowed_args)];
    mp_arg_parse_all(n_pos_args, pos_args, kw_args, MP_ARRAY_SIZE(allowed_args), allowed_args, args);

    // TODO:---- Check validity of arguments ----
    int8_t format = args[ARG_format].u_int;
    if ((format != PIXFORMAT_JPEG) &&
        (format != PIXFORMAT_YUV422) &&
        (format != PIXFORMAT_GRAYSCALE) &&
        (format != PIXFORMAT_RGB565)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Image format is not valid"));
    }

    int8_t size = args[ARG_framesize].u_int;
    if ((size != FRAMESIZE_96X96) &&
        (size != FRAMESIZE_QQVGA) &&
        (size != FRAMESIZE_QCIF) &&
        (size != FRAMESIZE_HQVGA) &&
        (size != FRAMESIZE_240X240) &&
        (size != FRAMESIZE_QVGA) &&
        (size != FRAMESIZE_CIF) &&
        (size != FRAMESIZE_HVGA) &&
        (size != FRAMESIZE_VGA) &&
        (size != FRAMESIZE_SVGA) &&
        (size != FRAMESIZE_XGA) &&
        (size != FRAMESIZE_HD) &&
        (size != FRAMESIZE_SXGA) &&
        (size != FRAMESIZE_UXGA) &&
        (size != FRAMESIZE_FHD) &&
        (size != FRAMESIZE_P_HD) &&
        (size != FRAMESIZE_P_3MP) &&
        (size != FRAMESIZE_QXGA) &&
        (size != FRAMESIZE_QHD) &&
        (size != FRAMESIZE_WQXGA) &&
        (size != FRAMESIZE_P_FHD) &&
        (size != FRAMESIZE_QSXGA)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Image framesize is not valid"));
    }


    int32_t xclk_freq = args[ARG_FREQ].u_int;
    if ((xclk_freq != XCLK_FREQ_10MHz) &&
        (xclk_freq != XCLK_FREQ_20MHz)) {
        mp_raise_ValueError(MP_ERROR_TEXT("xclk frequency is not valid"));
    }

    // configuring camera
    camera->config.pin_d0 = args[ARG_d0].u_int;
    camera->config.pin_d1 = args[ARG_d1].u_int;
    camera->config.pin_d2 = args[ARG_d2].u_int;
    camera->config.pin_d3 = args[ARG_d3].u_int;
    camera->config.pin_d4 = args[ARG_d4].u_int;
    camera->config.pin_d5 = args[ARG_d5].u_int;
    camera->config.pin_d6 = args[ARG_d6].u_int;
    camera->config.pin_d7 = args[ARG_d7].u_int;
    camera->config.pin_vsync = args[ARG_VSYNC].u_int;
    camera->config.pin_href = args[ARG_HREF].u_int;
    camera->config.pin_pclk = args[ARG_PCLK].u_int;
    camera->config.pin_pwdn = args[ARG_PWDN].u_int;
    camera->config.pin_reset = args[ARG_RESET].u_int;
    camera->config.pin_xclk = args[ARG_XCLK].u_int;
    camera->config.pin_sscb_sda = args[ARG_SIOD].u_int;
    camera->config.pin_sscb_scl = args[ARG_SIOC].u_int;
    camera->config.pixel_format = args[ARG_format].u_int;   //YUV422,GRAYSCALE,RGB565,JPEG
    camera->config.jpeg_quality = args[ARG_quality].u_int;  //0-63 lower number means higher quality

    // default parameters
    //XCLK 20MHz or 10MHz for OV2640 double FPS (Experimental)
    camera->config.xclk_freq_hz = args[ARG_FREQ].u_int;
    camera->config.ledc_timer = LEDC_TIMER_0;
    camera->config.ledc_channel = LEDC_CHANNEL_0;
    camera->config.frame_size = args[ARG_framesize].u_int; //QQVGA-QXGA Do not use sizes above QVGA when not JPEG
    camera->config.fb_count = 1; //if more than one, i2s runs in continuous mode. Use only with JPEG

    // camera->config.fb_location = CAMERA_FB_IN_DRAM; 
    esp_err_t err = esp_camera_init(&camera->config);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Camera Init Failed");
        mp_raise_msg(&mp_type_OSError, MP_ERROR_TEXT("Camera Init Failed"));

        return false;
    }

    return true;
}


STATIC mp_obj_t camera_init(mp_uint_t n_pos_args, const mp_obj_t *pos_args, mp_map_t *kw_args) {

    camera_obj_t camera_obj;
    
    bool camera = camera_init_helper(&camera_obj, n_pos_args - 1, pos_args + 1, kw_args);

    if (camera) {
        return mp_const_true;
    }
    else
    {
        return mp_const_false;
    }
}
STATIC MP_DEFINE_CONST_FUN_OBJ_KW(camera_init_obj, 1, camera_init);


STATIC mp_obj_t camera_deinit(){
    esp_err_t err = esp_camera_deinit();
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Camera deinit Failed");
        return mp_const_false;
    }

    return mp_const_true;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_deinit_obj, camera_deinit);


STATIC mp_obj_t camera_capture(){
    //acquire a frame
    camera_fb_t * fb = esp_camera_fb_get();
    if (!fb) {
        ESP_LOGE(TAG, "Camera Capture Failed");
        return mp_const_false;
    }

    mp_obj_t image = mp_obj_new_bytes(fb->buf, fb->len);

    //return the frame buffer back to the driver for reuse
    esp_camera_fb_return(fb);
    return image;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_capture_obj, camera_capture);

STATIC mp_obj_t camera_set_vflip(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Vertical flipping Failed");
        return mp_const_false;
      }
    int direction = mp_obj_get_int(what);
    s->set_vflip(s, direction);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_vflip_obj, camera_set_vflip);

STATIC mp_obj_t camera_get_vflip(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Vertical flipping Failed");
        return mp_const_false;
      }
    int direction = s->status.vflip;
    return mp_obj_new_int(direction);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_vflip_obj, camera_get_vflip);

STATIC mp_obj_t camera_set_hmirror(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Vertical flipping Failed");
        return mp_const_false;
      }
    int direction = mp_obj_get_int(what);
    s->set_hmirror(s, direction);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_hmirror_obj, camera_set_hmirror);

STATIC mp_obj_t camera_get_hmirror(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Getting vertical flip failed");
        return mp_const_false;
      }
    int direction = s->status.hmirror;
    return mp_obj_new_int(direction);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_hmirror_obj, camera_get_hmirror);

STATIC mp_obj_t camera_set_pixformat(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Pixformat Failed");
        return mp_const_false;
      }
    int size = mp_obj_get_int(what);
    if (size == 0) {
      s->set_pixformat(s, PIXFORMAT_JPEG); // JPEG (default) compress
    } else if (size == 1) {
      s->set_pixformat(s, PIXFORMAT_GRAYSCALE); // Grayscale 1 byte/pixel
    } else if (size == 2) {
      s->set_pixformat(s, PIXFORMAT_RGB565); // Red Green Blue 3 bytes/pixcel
    }
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_pixformat_obj, camera_set_pixformat);

STATIC mp_obj_t camera_set_framesize(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Set framesize Failed");
        return mp_const_false;
      }
    int size = mp_obj_get_int(what);
    /* same as in screen.h */
    if ((size != FRAMESIZE_96X96) &&
        (size != FRAMESIZE_QQVGA) &&
        (size != FRAMESIZE_QCIF) &&
        (size != FRAMESIZE_HQVGA) &&
        (size != FRAMESIZE_240X240) &&
        (size != FRAMESIZE_QVGA) &&
        (size != FRAMESIZE_CIF) &&
        (size != FRAMESIZE_HVGA) &&
        (size != FRAMESIZE_VGA) &&
        (size != FRAMESIZE_SVGA) &&
        (size != FRAMESIZE_XGA) &&
        (size != FRAMESIZE_HD) &&
        (size != FRAMESIZE_SXGA) &&
        (size != FRAMESIZE_UXGA) &&
        (size != FRAMESIZE_FHD) &&
        (size != FRAMESIZE_P_HD) &&
        (size != FRAMESIZE_P_3MP) &&
        (size != FRAMESIZE_QXGA) &&
        (size != FRAMESIZE_QHD) &&
        (size != FRAMESIZE_WQXGA) &&
        (size != FRAMESIZE_P_FHD) &&
        (size != FRAMESIZE_QSXGA)) {
        mp_raise_ValueError(MP_ERROR_TEXT("Image framesize is not valid"));
    }

    s->set_framesize(s,size);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_framesize_obj, camera_set_framesize);

STATIC mp_obj_t camera_get_framesize(){
  int framesize;
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Get framesize Failed");
        return mp_const_false;
      }
    framesize = s->status.framesize;
    return mp_obj_new_int(framesize);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_framesize_obj, camera_get_framesize);

STATIC mp_obj_t camera_set_quality(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Quality Failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what); // 10-63 lower number means higher quality
    s->set_quality(s, val);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_quality_obj, camera_set_quality);

STATIC mp_obj_t camera_get_quality(){
    int quality;
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Get quality Failed");
        return mp_const_false;
      }
    quality = s->status.quality;
    return mp_obj_new_int(quality);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_quality_obj, camera_get_quality);

STATIC mp_obj_t camera_set_contrast(mp_obj_t what){
    //acquire a frame
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Set contrast Failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what); // -2,2 (default 0). 2 highcontrast
    s->set_contrast(s, val);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_contrast_obj, camera_set_contrast);

STATIC mp_obj_t camera_get_contrast(){
    int contrast;  
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Get contrast Failed");
        return mp_const_false;
      }
    contrast = s->status.contrast;
    return  mp_obj_new_int(contrast);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_contrast_obj, camera_get_contrast);

STATIC mp_obj_t camera_set_saturation(mp_obj_t what){
    //acquire a frame
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Set saturation Failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_saturation(s, val); // -2,2 (default 0). -2 grayscale
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_saturation_obj, camera_set_saturation);

STATIC mp_obj_t camera_get_saturation(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Get saturation Failed");
        return mp_const_false;
      }
    int saturation = s->status.saturation;
    return mp_obj_new_int(saturation);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_saturation_obj, camera_get_saturation);

STATIC mp_obj_t camera_set_gainceiling(mp_obj_t what){
    //acquire a frame
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting gain ceiling failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_gainceiling(s, val); // -2,2 (default 0). -2 grayscale
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_gainceiling_obj, camera_set_gainceiling);

STATIC mp_obj_t camera_get_gainceiling(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting gain ceiling failed");
        return mp_const_false;
      }
    int gainceiling = s->status.gainceiling;
    return mp_obj_new_int(gainceiling);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_gainceiling_obj, camera_get_gainceiling);

STATIC mp_obj_t camera_set_colorbar(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting color bar failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_colorbar(s, val); 
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_colorbar_obj, camera_set_colorbar);

STATIC mp_obj_t camera_get_colorbar(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting color bar failed");
        return mp_const_false;
      }
    int colorbar = s->status.colorbar;
    return mp_obj_new_int(colorbar);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_colorbar_obj, camera_get_colorbar);

STATIC mp_obj_t camera_set_brightness(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Brightness Failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_brightness(s, val); // -2,2 (default 0). 2 brightest
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_brightness_obj, camera_set_brightness);

STATIC mp_obj_t camera_get_brightness(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting color bar failed");
        return mp_const_false;
      }
    int brightness = s->status.brightness;
    return mp_obj_new_int(brightness);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_brightness_obj, camera_get_brightness);

STATIC mp_obj_t camera_set_speffect(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Special Effect Failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_special_effect(s, val); // 0-6 (default 0). 
                                   // 0 - no effect
				   // 1 - negative
				   // 2 - black and white
				   // 3 - reddish
				   // 4 - greenish
				   // 5 - blue
				   // 6 - retro
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_speffect_obj, camera_set_speffect);

STATIC mp_obj_t camera_get_speffect(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Special Effect Failed");
        return mp_const_false;
      }
    int special_effect = s->status.special_effect;
                                   // 0-6 (default 0). 
                                   // 0 - no effect
				   // 1 - negative
				   // 2 - black and white
				   // 3 - reddish
				   // 4 - greenish
				   // 5 - blue
				   // 6 - retro
    return mp_obj_new_int(special_effect);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_speffect_obj, camera_get_speffect);

STATIC mp_obj_t camera_set_wb_mode(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "White Balance Mode Failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_wb_mode(s, val); // 0-4 (default 0).
                                   // 0 - no effect
                                   // 1 - sunny
                                   // 2 - cloudy
                                   // 3 - office
                                   // 4 - home
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_wb_mode_obj, camera_set_wb_mode);

STATIC mp_obj_t camera_get_wb_mode(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "White Balance Mode Failed");
        return mp_const_false;
      }
    int wb_mode = s->status.wb_mode; // 0-4 (default 0).
                                     // 0 - no effect
                                     // 1 - sunny
                                     // 2 - cloudy
                                     // 3 - office
                                     // 4 - home
    return mp_obj_new_int(wb_mode);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_wb_mode_obj, camera_get_wb_mode);

STATIC mp_obj_t camera_set_whitebal(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "White Balance Failed");
        return mp_const_false;
    }
    int val = mp_obj_get_int(what);
    s->set_whitebal(s, val); 
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_whitebal_obj, camera_set_whitebal);
 
STATIC mp_obj_t camera_get_whitebal(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "White Balance Failed");
        return mp_const_false;
      }
    int whitebal = s->status.awb;
    return mp_obj_new_int(whitebal);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_whitebal_obj, camera_get_whitebal);

STATIC mp_obj_t camera_set_aelevel(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting ae level failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_ae_level(s, val); // -2 to +2 (default 0).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_aelevel_obj, camera_set_aelevel);

STATIC mp_obj_t camera_get_aelevel(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Getting ae level failed");
        return mp_const_false;
      }
    int ae_level = s->status.ae_level;
    return mp_obj_new_int(ae_level);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_aelevel_obj, camera_get_aelevel);

STATIC mp_obj_t camera_set_aec_value(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "AEC Value Failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_aec_value(s, val);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_aec_value_obj, camera_set_aec_value);

STATIC mp_obj_t camera_get_aec_value(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "AEC Value Failed");
        return mp_const_false;
      }
    int aec_value = s->status.aec_value;
    return mp_obj_new_int(aec_value);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_aec_value_obj, camera_get_aec_value);

STATIC mp_obj_t camera_set_aec2(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting aec2 failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_aec2(s, val); // 0 to 1200 (default 0).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_aec2_obj, camera_set_aec2);

STATIC mp_obj_t camera_get_aec2(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Getting aec2 failed");
        return mp_const_false;
      }
    int aec2 = s->status.aec2; 
    return mp_obj_new_int(aec2);;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_aec2_obj, camera_get_aec2);

STATIC mp_obj_t camera_set_dcw(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting dcw failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_dcw(s, val); // 0 to 1200 (default 0).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_dcw_obj, camera_set_dcw);

STATIC mp_obj_t camera_get_dcw(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting dcw failed");
        return mp_const_false;
      }
    int dcw = s->status.dcw;
    return mp_obj_new_int(dcw);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_dcw_obj, camera_get_dcw);

STATIC mp_obj_t camera_set_bpc(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting bpc failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_bpc(s, val); // 0 to 1200 (default 0).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_bpc_obj, camera_set_bpc);

STATIC mp_obj_t camera_get_bpc(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting dcw failed");
        return mp_const_false;
      }
    int bpc = s->status.bpc;
    return mp_obj_new_int(bpc);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_bpc_obj, camera_get_bpc);

STATIC mp_obj_t camera_set_wpc(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting wpc failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_wpc(s, val); // 0 to 1200 (default 0).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_wpc_obj, camera_set_wpc);

STATIC mp_obj_t camera_get_wpc(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting dcw failed");
        return mp_const_false;
      }
    int wpc = s->status.wpc;
    return mp_obj_new_int(wpc);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_wpc_obj, camera_get_wpc);

STATIC mp_obj_t camera_set_raw_gma(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting raw_gma failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_raw_gma(s, val); // 0 to 1200 (default 0).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_raw_gma_obj, camera_set_raw_gma);

STATIC mp_obj_t camera_get_raw_gma(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting raw_gma failed");
        return mp_const_false;
      }
    int raw_gma = s->status.raw_gma; // 0 to 1200 (default 0).
    return mp_obj_new_int(raw_gma);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_raw_gma_obj, camera_get_raw_gma);

STATIC mp_obj_t camera_set_lenc(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting lenc failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_lenc(s, val); // 0 to 1200 (default 0).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_lenc_obj, camera_set_lenc);

STATIC mp_obj_t camera_get_lenc(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting lenc failed");
        return mp_const_false;
      }
    int lenc = s->status.lenc;
    return mp_obj_new_int(lenc);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_lenc_obj, camera_get_lenc);

STATIC mp_obj_t camera_set_agc_gain(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Set agc gain failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_agc_gain(s, val); // 0 to 30 (default 30).
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_agc_gain_obj, camera_set_agc_gain);

STATIC mp_obj_t camera_get_agc_gain(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Get agc gain failed");
        return mp_const_false;
      }
    int agc_gain = s->status.agc_gain;
    return mp_obj_new_int(agc_gain);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_agc_gain_obj, camera_get_agc_gain);

STATIC mp_obj_t camera_set_awb_gain(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting awb gain failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_awb_gain(s, val); 
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_awb_gain_obj, camera_set_awb_gain);

STATIC mp_obj_t camera_get_awb_gain(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Getting awb gain failed");
        return mp_const_false;
      }
    int awb_gain = s->status.awb_gain;
    return mp_obj_new_int(awb_gain);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_awb_gain_obj, camera_get_awb_gain);

STATIC mp_obj_t camera_set_gain_ctrl(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting gain control failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_gain_ctrl(s, val); 
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_gain_ctrl_obj, camera_set_gain_ctrl);

STATIC mp_obj_t camera_get_gain_ctrl(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting gain control failed");
        return mp_const_false;
      }
    int agc = s->status.agc;
    return mp_obj_new_int(agc);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_gain_ctrl_obj, camera_get_gain_ctrl);

STATIC mp_obj_t camera_set_exposure_ctrl(mp_obj_t what){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Setting exposure control failed");
        return mp_const_false;
      }
    int val = mp_obj_get_int(what);
    s->set_exposure_ctrl(s, val); 
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(camera_set_exposure_ctrl_obj, camera_set_exposure_ctrl);

STATIC mp_obj_t camera_get_exposure_ctrl(){
    sensor_t * s = esp_camera_sensor_get();
    if (!s) {
        ESP_LOGE(TAG, "Getting exposure control failed");
        return mp_const_false;
      }
    int aec = s->status.aec;
    return mp_obj_new_int(aec);
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(camera_get_exposure_ctrl_obj, camera_get_exposure_ctrl);

STATIC const mp_rom_map_elem_t camera_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_camera) },

    { MP_ROM_QSTR(MP_QSTR_init), MP_ROM_PTR(&camera_init_obj) },
    { MP_ROM_QSTR(MP_QSTR_deinit), MP_ROM_PTR(&camera_deinit_obj) },
    { MP_ROM_QSTR(MP_QSTR_capture), MP_ROM_PTR(&camera_capture_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_vflip), MP_ROM_PTR(&camera_set_vflip_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_vflip), MP_ROM_PTR(&camera_get_vflip_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_hmirror), MP_ROM_PTR(&camera_set_hmirror_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_hmirror), MP_ROM_PTR(&camera_get_hmirror_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_pixformat), MP_ROM_PTR(&camera_set_pixformat_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_framesize), MP_ROM_PTR(&camera_set_framesize_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_framesize), MP_ROM_PTR(&camera_get_framesize_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_quality), MP_ROM_PTR(&camera_set_quality_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_quality), MP_ROM_PTR(&camera_get_quality_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_contrast), MP_ROM_PTR(&camera_set_contrast_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_contrast), MP_ROM_PTR(&camera_get_contrast_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_saturation), MP_ROM_PTR(&camera_set_saturation_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_saturation), MP_ROM_PTR(&camera_get_saturation_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_gainceiling), MP_ROM_PTR(&camera_set_gainceiling_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_gainceiling), MP_ROM_PTR(&camera_get_gainceiling_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_gain_ctrl), MP_ROM_PTR(&camera_set_gain_ctrl_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_gain_ctrl), MP_ROM_PTR(&camera_get_gain_ctrl_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_exposure_ctrl), MP_ROM_PTR(&camera_set_exposure_ctrl_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_exposure_ctrl), MP_ROM_PTR(&camera_get_exposure_ctrl_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_colorbar), MP_ROM_PTR(&camera_set_colorbar_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_colorbar), MP_ROM_PTR(&camera_get_colorbar_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_brightness), MP_ROM_PTR(&camera_set_brightness_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_brightness), MP_ROM_PTR(&camera_get_brightness_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_speffect), MP_ROM_PTR(&camera_set_speffect_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_speffect), MP_ROM_PTR(&camera_get_speffect_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_wb_mode), MP_ROM_PTR(&camera_set_wb_mode_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_wb_mode), MP_ROM_PTR(&camera_get_wb_mode_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_whitebal), MP_ROM_PTR(&camera_set_whitebal_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_whitebal), MP_ROM_PTR(&camera_get_whitebal_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_aelevel), MP_ROM_PTR(&camera_set_aelevel_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_aelevel), MP_ROM_PTR(&camera_get_aelevel_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_aec_value), MP_ROM_PTR(&camera_set_aec_value_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_aec_value), MP_ROM_PTR(&camera_get_aec_value_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_aec2), MP_ROM_PTR(&camera_set_aec2_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_aec2), MP_ROM_PTR(&camera_get_aec2_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_dcw), MP_ROM_PTR(&camera_set_dcw_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_dcw), MP_ROM_PTR(&camera_get_dcw_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_bpc), MP_ROM_PTR(&camera_set_bpc_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_bpc), MP_ROM_PTR(&camera_get_bpc_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_wpc), MP_ROM_PTR(&camera_set_wpc_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_wpc), MP_ROM_PTR(&camera_get_wpc_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_raw_gma), MP_ROM_PTR(&camera_set_raw_gma_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_raw_gma), MP_ROM_PTR(&camera_get_raw_gma_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_lenc), MP_ROM_PTR(&camera_set_lenc_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_lenc), MP_ROM_PTR(&camera_get_lenc_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_awb_gain), MP_ROM_PTR(&camera_set_awb_gain_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_awb_gain), MP_ROM_PTR(&camera_get_awb_gain_obj) },
    { MP_ROM_QSTR(MP_QSTR_set_agc_gain), MP_ROM_PTR(&camera_set_agc_gain_obj) },
    { MP_ROM_QSTR(MP_QSTR_get_agc_gain), MP_ROM_PTR(&camera_get_agc_gain_obj) },

    // Constants
    { MP_ROM_QSTR(MP_QSTR_JPEG),            MP_ROM_INT(PIXFORMAT_JPEG) },
    { MP_ROM_QSTR(MP_QSTR_YUV422),          MP_ROM_INT(PIXFORMAT_YUV422) },
    { MP_ROM_QSTR(MP_QSTR_GRAYSCALE),       MP_ROM_INT(PIXFORMAT_GRAYSCALE) },
    { MP_ROM_QSTR(MP_QSTR_RGB565),          MP_ROM_INT(PIXFORMAT_RGB565) },
    
    { MP_ROM_QSTR(MP_QSTR_FRAME_96X96),     MP_ROM_INT(FRAMESIZE_96X96) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_QQVGA),     MP_ROM_INT(FRAMESIZE_QQVGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_QCIF),      MP_ROM_INT(FRAMESIZE_QCIF) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_HQVGA),     MP_ROM_INT(FRAMESIZE_HQVGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_240X240),   MP_ROM_INT(FRAMESIZE_240X240) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_QVGA),      MP_ROM_INT(FRAMESIZE_QVGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_CIF),       MP_ROM_INT(FRAMESIZE_CIF) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_HVGA),      MP_ROM_INT(FRAMESIZE_HVGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_VGA),       MP_ROM_INT(FRAMESIZE_VGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_SVGA),      MP_ROM_INT(FRAMESIZE_SVGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_XGA),       MP_ROM_INT(FRAMESIZE_XGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_HD),        MP_ROM_INT(FRAMESIZE_HD) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_SXGA),      MP_ROM_INT(FRAMESIZE_SXGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_UXGA),      MP_ROM_INT(FRAMESIZE_UXGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_FHD),       MP_ROM_INT(FRAMESIZE_FHD) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_P_HD),      MP_ROM_INT(FRAMESIZE_P_HD) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_P_3MP),     MP_ROM_INT(FRAMESIZE_P_3MP) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_QXGA),      MP_ROM_INT(FRAMESIZE_QXGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_QHD),       MP_ROM_INT(FRAMESIZE_QHD) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_WQXGA),     MP_ROM_INT(FRAMESIZE_WQXGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_P_FHD),     MP_ROM_INT(FRAMESIZE_P_FHD) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_QSXGA),     MP_ROM_INT(FRAMESIZE_QSXGA) },
    { MP_ROM_QSTR(MP_QSTR_FRAME_QSXGA),     MP_ROM_INT(FRAMESIZE_QSXGA) },

    { MP_ROM_QSTR(MP_QSTR_WB_NONE),         MP_ROM_INT(WB_NONE) },
    { MP_ROM_QSTR(MP_QSTR_WB_SUNNY),        MP_ROM_INT(WB_SUNNY) },
    { MP_ROM_QSTR(MP_QSTR_WB_CLOUDY),       MP_ROM_INT(WB_CLOUDY) },
    { MP_ROM_QSTR(MP_QSTR_WB_OFFICE),       MP_ROM_INT(WB_OFFICE) },
    { MP_ROM_QSTR(MP_QSTR_WB_HOME),         MP_ROM_INT(WB_HOME) },

    { MP_ROM_QSTR(MP_QSTR_EFFECT_NONE),     MP_ROM_INT(EFFECT_NONE) },
    { MP_ROM_QSTR(MP_QSTR_EFFECT_NEG),      MP_ROM_INT(EFFECT_NEG) },
    { MP_ROM_QSTR(MP_QSTR_EFFECT_BW),       MP_ROM_INT(EFFECT_BW) },
    { MP_ROM_QSTR(MP_QSTR_EFFECT_RED),      MP_ROM_INT(EFFECT_RED) },
    { MP_ROM_QSTR(MP_QSTR_EFFECT_GREEN),    MP_ROM_INT(EFFECT_GREEN) },
    { MP_ROM_QSTR(MP_QSTR_EFFECT_BLUE),     MP_ROM_INT(EFFECT_BLUE) },
    { MP_ROM_QSTR(MP_QSTR_EFFECT_RETRO),    MP_ROM_INT(EFFECT_RETRO) },

    { MP_ROM_QSTR(MP_QSTR_XCLK_10MHz),      MP_ROM_INT(XCLK_FREQ_10MHz) },
    { MP_ROM_QSTR(MP_QSTR_XCLK_20MHz),      MP_ROM_INT(XCLK_FREQ_20MHz) },

};

STATIC MP_DEFINE_CONST_DICT(camera_module_globals, camera_module_globals_table);

const mp_obj_module_t mp_module_camera_system = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&camera_module_globals,
};

MP_REGISTER_MODULE(MP_QSTR_camera, mp_module_camera_system);


#endif
