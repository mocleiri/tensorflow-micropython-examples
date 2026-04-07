# Improve `microlite` Help Output

## Goal

Make on-device introspection of the `microlite` module more useful, especially for:

- `help(microlite)`
- `help(microlite.interpreter)`
- `help(microlite.tensor)`
- `help(microlite.audio_frontend)`

The main gap today is that MicroPython's built-in `help()` only shows C-exposed methods as generic `<function>` entries and does not include argument names or rich signatures for functions defined with `MP_DEFINE_CONST_FUN_OBJ_*`.

## Current Output Example

Current REPL output looks like this:

```python
>>> help (microlite)
object <module 'microlite'> is of type module
  __name__ -- microlite
  __version__ -- e87305ee53c124188d0390b1ef8ec0555760d4d6
  interpreter -- <class 'interpreter'>
  tensor -- <class 'tensor'>
  audio_frontend -- <class 'audio_frontend'>
>>> help (microlite.interpreter)
object <class 'interpreter'> is of type type
  invoke -- <function>
  getInputTensor -- <function>
  getOutputTensor -- <function>
```

This is functional, but it does not show constructor usage, argument names, return values, or any hints about what the methods expect.

## Recommended Approach

### 1. Add explicit help methods

Add lightweight help methods that print usage and method signatures:

- `microlite.help()`
- `microlite.interpreter.help()`
- `microlite.tensor.help()`
- `microlite.audio_frontend.help()`

These should print concise, copy-pasteable usage text such as:

```python
microlite.interpreter(model_data, tensor_arena_size)
  invoke()
  getInputTensor(index)
  getOutputTensor(index)
```

This is the most reliable MicroPython-native solution because it does not depend on unsupported introspection features.

### 2. Add module/class doc strings or help constants

Expose short descriptive strings as attributes/constants, for example:

- `microlite.__doc__`
- `microlite.INTERPRETER_HELP`
- `microlite.TENSOR_HELP`
- `microlite.AUDIO_FRONTEND_HELP`

If `__doc__` support is awkward for these C-defined objects, plain named constants are fine.

These strings should document:

- constructor signatures
- argument meanings
- return values
- common usage patterns

### 3. Improve object `print`/`repr`

Enhance existing print handlers so object instances show useful runtime detail, for example:

- interpreter: model size, tensor arena size, input/output tensor count if available
- tensor: type, dimensions, quantization params when relevant
- audio_frontend: configured/unconfigured state

This complements `help()` and makes REPL exploration easier.

### 4. Optionally add frozen Python wrappers later

If richer docs and nicer Pythonic naming are desired, add a thin frozen Python API layer that wraps the C objects and provides:

- docstrings
- friendlier method names
- convenience validation/helpers

This is optional and should only be done if the lighter C-side help additions are not sufficient.

## Non-Goals

- Do not try to make MicroPython `help()` automatically infer C argument names; the runtime does not provide CPython-style signature introspection for these bindings.
- Do not rely on `MP_DEFINE_CONST_FUN_OBJ_*` metadata alone to improve printed help; it only captures arity, not argument names or descriptions.

## Suggested Implementation Order

1. Add `microlite.help()`
2. Add `interpreter.help()`, `tensor.help()`, and `audio_frontend.help()`
3. Add exported help/doc constants
4. Improve `print` output for runtime objects
5. Reassess whether frozen Python wrappers are still needed

## Candidate Signatures To Document

Based on the current binding shape:

- `microlite.interpreter(model_data, tensor_arena_size)`
- `interpreter.invoke()`
- `interpreter.getInputTensor(index)`
- `interpreter.getOutputTensor(index)`
- `tensor.getType()`
- `tensor.getValue(index)`
- `tensor.setValue(index, value)`
- `tensor.quantizeFloatToInt8(value)`
- `tensor.quantizeInt8ToFloat(value)`
- `audio_frontend.configure()`
- `audio_frontend.execute(input)`

These should be verified against the actual constructor and method behavior during implementation.
