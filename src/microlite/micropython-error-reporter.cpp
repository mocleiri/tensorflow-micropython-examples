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

#include <cstdarg>

namespace microlite {

int MicropythonErrorReporter::Report(const char* format, ...) {

    va_list args;
    va_start(args, format);
    MicropythonErrorReporter::Report(format, args);
    va_end(args);

    return 0;

}

int MicropythonErrorReporter::Report(const char* format, va_list args) {

    static constexpr int kMaxLogLen = 256;
    char log_buffer[kMaxLogLen];

    MicroVsnprintf(log_buffer, kMaxLogLen, format, args);

    mp_printf(MP_PYTHON_PRINTER, log_buffer);
    mp_printf(MP_PYTHON_PRINTER, log_buffer);

    return 0;

}

} // end microlite
