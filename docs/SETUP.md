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

The output will consist of both the amount of time each version took to run the test
suite, using the `time` command, as well as whether or not each test passed or failed.
Tests are considered to have `FAILED` if the difference between the value that FUSTAL
returns and R returns is greater than **0.00001**.

## Adding tests to the test suite

Adding a test to the test suite is not particularly difficult, as the previous
test suite has been revamped to not be dependent on the order of the tests.

### Adding a test to `test.py`

To add a test to `test.py`, generally you only need to add it to one of the
predefined lists of functions, provided it takes the same arguments that they
do. Otherwise, if you have to define your own data for the test, you need
to ensure that your output is in CSV format.

Here is an example print statement:
```python
print("py", sanitize(func.__name__), func(data), sep=",")
```

Where `func` is the new function that you are writing the test for, sanitize is a
predefined function that removes the string `futhark_entry_` from the beginning of the
name of the function, and data is your custom data.

### Adding a test to `test.R`

This is often a bit trickier to do than `test.py`, but if it is a built in
test then it's pretty easy. Generally, you want to coax R into *only* printing
the values for the test - the easiest way to do this is to wrap all output
with `as.vector()`.

Example Test in R:
```R
"my_new_test"
as.vector(my_new_test(data))
```

### Running the suite

Now just run `./test` and see if it passes.

If all goes well, you won't see any tests fail. If you want to see the actual
results of each library, you can view the file `output/test-output.csv`.
