# Setting up a development environment

Principally, the only **required** piece of software
is the futhark compiler itself, available from
[diku-dk/futhark](https://github.com/diku-dk/futhark).
You can use the latest binary release, or you can compile
it from source.

**NOTE:** Compiling from source takes several minutes and having
GHC >= 9.0 installed.

This is technically all that is needed to build the library, however
to make it easily accessible from python, you also need to install
[pepijndevos/futhark-pycffi](https://github.com/pepijndevos/futhark-pycffi)
which is available via pip as `futhark-ffi`

**NOTE:** If installing via pip for the local user, make sure that `$HOME/.local/bin`
is in your `$PATH`.

# Building the library

Enter into the root of the directory, and simply run:

```sh
./build
```

You can customize the build to a limited degree as well.

For example, the following code will build a CUDA version of the
library as well as build the PDF version of the documentation:

```sh
FUTHARK_TARGET=cuda BUILD_DOCS=1 ./build
```

Valid `FUTHARK_TARGET`s:
* c
* multicore
* opencl
* cuda

**NOTE:** `ispc` is *not* a valid target.

**NOTE:** To build the PDF documentation, you need to have LaTeX installed, and `latexmk` in the system `$PATH`.
