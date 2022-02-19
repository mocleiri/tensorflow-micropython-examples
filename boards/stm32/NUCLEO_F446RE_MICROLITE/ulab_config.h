// Determines, whether scipy is defined in ulab. The sub-modules and functions
// of scipy have to be defined separately
#define ULAB_HAS_SCIPY                      (0)

// The maximum number of dimensions the firmware should be able to support
// Possible values lie between 1, and 4, inclusive
#define ULAB_MAX_DIMS                       2

// By setting this constant to 1, iteration over array dimensions will be implemented
// as a function (ndarray_rewind_array), instead of writing out the loops in macros
// This reduces firmware size at the expense of speed
#define ULAB_HAS_FUNCTION_ITERATOR          (0)

// If NDARRAY_IS_ITERABLE is 1, the ndarray object defines its own iterator function
// This option saves approx. 250 bytes of flash space
#define NDARRAY_IS_ITERABLE                 (1)

// Slicing can be switched off by setting this variable to 0
#define NDARRAY_IS_SLICEABLE                (0)

// The default threshold for pretty printing. These variables can be overwritten
// at run-time via the set_printoptions() function
#define ULAB_HAS_PRINTOPTIONS               (1)

// determines, whether the dtype is an object, or simply a character
// the object implementation is numpythonic, but requires more space
#define ULAB_HAS_DTYPE_OBJECT               (0)

// the ndarray binary operators
#define NDARRAY_HAS_BINARY_OPS              (0)

// Firmware size can be reduced at the expense of speed by using function
// pointers in iterations. For each operator, he function pointer saves around
// 2 kB in the two-dimensional case, and around 4 kB in the four-dimensional case.

#define NDARRAY_BINARY_USES_FUN_POINTER     (0)

#define NDARRAY_HAS_BINARY_OP_ADD           (0)

#define NDARRAY_HAS_BINARY_OP_EQUAL         (0)

#define NDARRAY_HAS_BINARY_OP_LESS          (0)


#define NDARRAY_HAS_BINARY_OP_LESS_EQUAL    (0)



#define NDARRAY_HAS_BINARY_OP_MORE          (0)



#define NDARRAY_HAS_BINARY_OP_MORE_EQUAL    (0)



#define NDARRAY_HAS_BINARY_OP_MULTIPLY      (0)



#define NDARRAY_HAS_BINARY_OP_NOT_EQUAL     (0)



#define NDARRAY_HAS_BINARY_OP_POWER         (0)



#define NDARRAY_HAS_BINARY_OP_SUBTRACT      (0)



#define NDARRAY_HAS_BINARY_OP_TRUE_DIVIDE   (0)



#define NDARRAY_HAS_INPLACE_OPS             (0)



#define NDARRAY_HAS_INPLACE_ADD             (0)



#define NDARRAY_HAS_INPLACE_MULTIPLY        (0)



#define NDARRAY_HAS_INPLACE_POWER           (0)



#define NDARRAY_HAS_INPLACE_SUBTRACT        (0)



#define NDARRAY_HAS_INPLACE_TRUE_DIVIDE     (0)


// the ndarray unary operators

#define NDARRAY_HAS_UNARY_OPS               (0)



#define NDARRAY_HAS_UNARY_OP_ABS            (0)



#define NDARRAY_HAS_UNARY_OP_INVERT         (0)



#define NDARRAY_HAS_UNARY_OP_LEN            (0)



#define NDARRAY_HAS_UNARY_OP_NEGATIVE       (0)



#define NDARRAY_HAS_UNARY_OP_POSITIVE       (0)



// determines, which ndarray methods are available

#define NDARRAY_HAS_BYTESWAP            (0)



#define NDARRAY_HAS_COPY                (0)



#define NDARRAY_HAS_DTYPE               (0)



#define NDARRAY_HAS_FLATTEN             (0)



#define NDARRAY_HAS_ITEMSIZE            (0)



#define NDARRAY_HAS_RESHAPE             (0)



#define NDARRAY_HAS_SHAPE               (0)



#define NDARRAY_HAS_SIZE                (1)



#define NDARRAY_HAS_SORT                (0)



#define NDARRAY_HAS_STRIDES             (0)



#define NDARRAY_HAS_TOBYTES             (1)



#define NDARRAY_HAS_TRANSPOSE           (0)


// Firmware size can be reduced at the expense of speed by using a function
// pointer in iterations. Setting ULAB_VECTORISE_USES_FUNCPOINTER to 1 saves
// around 800 bytes in the four-dimensional case, and around 200 in two dimensions.

#define ULAB_VECTORISE_USES_FUN_POINTER (1)


// determines, whether e is defined in ulab.numpy itself

#define ULAB_NUMPY_HAS_E                (0)


// ulab defines infinite as a class constant in ulab.numpy

#define ULAB_NUMPY_HAS_INF              (0)


// ulab defines NaN as a class constant in ulab.numpy

#define ULAB_NUMPY_HAS_NAN              (0)


// determines, whether pi is defined in ulab.numpy itself

#define ULAB_NUMPY_HAS_PI               (0)


// determines, whether the ndinfo function is available

#define ULAB_NUMPY_HAS_NDINFO           (0)


// if this constant is set to 1, the interpreter can iterate
// over the flat array without copying any data

#define NDARRAY_HAS_FLATITER            (0)


// frombuffer adds 600 bytes to the firmware

#define ULAB_NUMPY_HAS_FROMBUFFER       (1)


// functions that create an array

#define ULAB_NUMPY_HAS_ARANGE           (0)



#define ULAB_NUMPY_HAS_CONCATENATE      (1)



#define ULAB_NUMPY_HAS_DIAG             (0)



#define ULAB_NUMPY_HAS_EMPTY            (0)



#define ULAB_NUMPY_HAS_EYE              (0)



#define ULAB_NUMPY_HAS_FULL             (0)



#define ULAB_NUMPY_HAS_LINSPACE         (0)



#define ULAB_NUMPY_HAS_LOGSPACE         (0)



#define ULAB_NUMPY_HAS_ONES             (0)



#define ULAB_NUMPY_HAS_ZEROS            (1)


// functions that compare arrays

#define ULAB_NUMPY_HAS_CLIP             (0)



#define ULAB_NUMPY_HAS_EQUAL            (0)



#define ULAB_NUMPY_HAS_ISFINITE         (0)



#define ULAB_NUMPY_HAS_ISINF            (0)



#define ULAB_NUMPY_HAS_MAXIMUM          (0)



#define ULAB_NUMPY_HAS_MINIMUM          (0)



#define ULAB_NUMPY_HAS_NOTEQUAL         (0)



#define ULAB_NUMPY_HAS_WHERE            (0)


// the linalg module; functions of the linalg module still have
// to be defined separately

#define ULAB_NUMPY_HAS_LINALG_MODULE    (0)



#define ULAB_LINALG_HAS_CHOLESKY        (0)



#define ULAB_LINALG_HAS_DET             (0)



#define ULAB_LINALG_HAS_EIG             (0)



#define ULAB_LINALG_HAS_INV             (0)



#define ULAB_LINALG_HAS_NORM            (0)



#define ULAB_LINALG_HAS_QR              (0)


// the FFT module; functions of the fft module still have
// to be defined separately

#define ULAB_NUMPY_HAS_FFT_MODULE       (0)



#define ULAB_FFT_HAS_FFT                (0)



#define ULAB_FFT_HAS_IFFT               (0)



#define ULAB_NUMPY_HAS_ALL              (0)



#define ULAB_NUMPY_HAS_ANY              (0)



#define ULAB_NUMPY_HAS_ARGMINMAX        (0)



#define ULAB_NUMPY_HAS_ARGSORT          (0)



#define ULAB_NUMPY_HAS_CONVOLVE         (0)



#define ULAB_NUMPY_HAS_CROSS            (0)



#define ULAB_NUMPY_HAS_DIFF             (0)



#define ULAB_NUMPY_HAS_DOT              (0)



#define ULAB_NUMPY_HAS_FLIP             (0)



#define ULAB_NUMPY_HAS_INTERP           (0)



#define ULAB_NUMPY_HAS_MEAN             (0)



#define ULAB_NUMPY_HAS_MEDIAN           (0)



#define ULAB_NUMPY_HAS_MINMAX           (0)



#define ULAB_NUMPY_HAS_POLYFIT          (0)



#define ULAB_NUMPY_HAS_POLYVAL          (0)



#define ULAB_NUMPY_HAS_ROLL             (0)



#define ULAB_NUMPY_HAS_SORT             (0)



#define ULAB_NUMPY_HAS_STD              (0)



#define ULAB_NUMPY_HAS_SUM              (0)



#define ULAB_NUMPY_HAS_TRACE            (0)



#define ULAB_NUMPY_HAS_TRAPZ            (0)


// vectorised versions of the functions of the math python module, with
// the exception of the functions listed in scipy.special

#define ULAB_NUMPY_HAS_ACOS             (0)



#define ULAB_NUMPY_HAS_ACOSH            (0)



#define ULAB_NUMPY_HAS_ARCTAN2          (0)



#define ULAB_NUMPY_HAS_AROUND           (0)



#define ULAB_NUMPY_HAS_ASIN             (0)



#define ULAB_NUMPY_HAS_ASINH            (0)



#define ULAB_NUMPY_HAS_ATAN             (0)



#define ULAB_NUMPY_HAS_ATANH            (0)



#define ULAB_NUMPY_HAS_CEIL             (0)



#define ULAB_NUMPY_HAS_COS              (0)



#define ULAB_NUMPY_HAS_COSH             (0)



#define ULAB_NUMPY_HAS_DEGREES          (0)



#define ULAB_NUMPY_HAS_EXP              (0)



#define ULAB_NUMPY_HAS_EXPM1            (0)



#define ULAB_NUMPY_HAS_FLOOR            (0)



#define ULAB_NUMPY_HAS_LOG              (0)



#define ULAB_NUMPY_HAS_LOG10            (0)



#define ULAB_NUMPY_HAS_LOG2             (0)



#define ULAB_NUMPY_HAS_RADIANS          (0)



#define ULAB_NUMPY_HAS_SIN              (0)



#define ULAB_NUMPY_HAS_SINH             (0)



#define ULAB_NUMPY_HAS_SQRT             (0)



#define ULAB_NUMPY_HAS_TAN              (0)



#define ULAB_NUMPY_HAS_TANH             (0)



#define ULAB_NUMPY_HAS_VECTORIZE        (0)



#define ULAB_SCIPY_HAS_LINALG_MODULE        (0)



#define ULAB_SCIPY_LINALG_HAS_CHO_SOLVE     (0)



#define ULAB_SCIPY_LINALG_HAS_SOLVE_TRIANGULAR  (0)



#define ULAB_SCIPY_HAS_SIGNAL_MODULE        (0)



#define ULAB_SCIPY_SIGNAL_HAS_SPECTROGRAM   (0)



#define ULAB_SCIPY_SIGNAL_HAS_SOSFILT       (0)



#define ULAB_SCIPY_HAS_OPTIMIZE_MODULE      (0)



#define ULAB_SCIPY_OPTIMIZE_HAS_BISECT      (0)



#define ULAB_SCIPY_OPTIMIZE_HAS_CURVE_FIT   (0) // not fully implemented



#define ULAB_SCIPY_OPTIMIZE_HAS_FMIN        (0)



#define ULAB_SCIPY_OPTIMIZE_HAS_NEWTON      (0)



#define ULAB_SCIPY_HAS_SPECIAL_MODULE       (0)



#define ULAB_SCIPY_SPECIAL_HAS_ERF          (0)



#define ULAB_SCIPY_SPECIAL_HAS_ERFC         (0)



#define ULAB_SCIPY_SPECIAL_HAS_GAMMA        (0)



#define ULAB_SCIPY_SPECIAL_HAS_GAMMALN      (0)


// user-defined module; source of the module and
// its sub-modules should be placed in code/user/

#define ULAB_HAS_USER_MODULE                (0)



#define ULAB_HAS_UTILS_MODULE               (0)



#define ULAB_UTILS_HAS_FROM_INT16_BUFFER    (1)



#define ULAB_UTILS_HAS_FROM_UINT16_BUFFER   (1)



#define ULAB_UTILS_HAS_FROM_INT32_BUFFER    (1)



#define ULAB_UTILS_HAS_FROM_UINT32_BUFFER   (1)



