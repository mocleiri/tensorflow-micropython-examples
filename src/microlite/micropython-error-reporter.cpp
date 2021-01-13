/*
 * This file is part of the Tensorflow Micropython Examples Project.
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2021 Michael O'Cleirigh
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
#include "micropython-error-reporter.h"

#if MICROPY_USE_INTERNAL_PRINTF
#include "py/mpprint.h"
#endif

#if CONFIG_IDF_TARGET_ESP32
#include "esp_log.h"
#endif

#include "py/qstr.h"

#include <cstdarg>

namespace microlite {

int MicropythonErrorReporter::Report(const char* format, va_list args) {

#if MICROPY_USE_INTERNAL_PRINTF
    return mp_vprintf(MP_PYTHON_PRINTER, format, args);
#else

#if CONFIG_IDF_TARGET_ESP32

  /*
   Needed on ESP32 because MICROPY_USE_INTERNAL_PRINTF is not enabled.

   So we don't have access to mp_vprintf used above.
   */

  esp_log_writev(esp_log_level_t.ESP_LOG_INFO, MP_QSTR_Microlite, format, args);

#else
    // need to find out what to use for other ports

#endif

#endif



  return 0;
}

} // end microlite
