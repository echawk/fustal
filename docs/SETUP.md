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
FUTHARK_TARGET=cuda BUILD_DOCS_PDF=1 ./build
```

**NOTE:** Building the PDF documentation requires `latexmk` to be present on your system.

Valid `FUTHARK_TARGET`s:

* c
* multicore
* opencl
* cuda

**NOTE:** `ispc` is *not* a valid target, as futhark-ffi does not support it yet.

To build the HTML version of the docs, run the following instead:

```sh
BUILD_DOCS_HTML=1 ./build
```

**NOTE:** This requires `make4ht` to be available on your system.

# Testing the library

Once the library is built, you can run the test suite by simply running:

```
./test
```

If all of the tests passed, the word "PASSED" will be printed, otherwise
it will print "FAILED".

## Adding tests to the test suite

Currently this process is far from streamlined. However the rough process is
as follows:

1. Implement the test in `test.py`, likely as the very last test.
2. Implement the test in `test.R`, again, likely as the very last test.
   * **NOTE:** You will likely want to wrap any numerical value with `as.vector()`.
3. Run `./test` and see if it passes.

I would like to make this setup far more streamlined in the future, with
the new system allowing for the tests to be printed in any order, since
presently each test has to be on the exact same line as its counterpart.
