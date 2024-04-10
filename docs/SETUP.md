# Setting up a development environment

## Using `./setup`

The `setup` script provided at the root of the project can be used to setup
a development environment capable of building the library. It supports
the 3 major operating systems (Linux, macOS, & Windows) and will download
the appropriate software required for each.

It does require that you have the following software installed:
* python3
* curl
* unzip (for Windows)

The following software is installed via the script:
* Futhark (via tarball)
* python libraries (via requirements.txt)

On windows the following sofware is installed:
* w64devkit (via zip archive)

**NOTE:** For Windows build environments, the only tested terminal/shell
is the one that is provided when one installs git (git bash).

## Manually

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
library as well as build the PDF & HTML versions of the documentation:

```sh
FUTHARK_TARGET=cuda BUILD_DOCS=1 ./build
```

**NOTE:** Building the PDF documentation requires `latexmk` to be present on your system.

**NOTE:** Building the HTML documentation requires `make4ht` to be available on your system.

Valid `FUTHARK_TARGET`s:

* c
* multicore
* opencl
* cuda

**NOTE:** `ispc` is *not* a valid target, as futhark-ffi does not support it yet.

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

Adding a test to the test suite is not particularly difficult, as much of the
process has been automated. It should be a 1 line change to the python code
and a 2 line change for the R code. Below will illustrate how to add a new
test, called **my_new_func** to each of the respective files.

### Adding a test to `test.py`

To add the test to `test.py`, generally you only need to add it to one of the
predefined lists of functions, provided it takes the same arguments that they
do. Otherwise, if you have to define your own data for the test, all that is
needed is to make your own statement using the `t` function.

Here is an example statement:
```python
t("my_new_func", ["data"])
```

Where `my_new_func` is the new function that you are writing the test for,
and `data` is the data that the function will use for testing.

### Adding a test to `test.R`

This is a bit trickier to do than `test.py`, but if it is a built in
test then it's pretty easy. Generally, you want to coax R into *only* printing
the values for the test - the easiest way to do this is to wrap all output
with `as.vector()`.

Example Test in R:
```R
"my_new_func"
timer(quote(as.vector(my_new_test(data))))
```

### Running the suite

Now just run `./test` and see if it passes.

If all goes well, you won't see any tests fail. If you want to see the actual
results of each library, you can view the file `output/test-output.csv`.
