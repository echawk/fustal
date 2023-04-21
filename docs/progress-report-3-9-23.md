# Progress Report, 2023-03-09, Ethan Hawk

## Tests Implemented:

* wilcoxon rank sum test
  * currently WIP, since R reports a different value.
* simple linear regression
* chi squared test
* f test (one way anova)
* pearson correlation coefficient
* two sample t test
* one sample t test

In addition to all of these statistical tests,
a test suite has also been written to confirm that
the results are consistent to what you would get from R.

Results are measured to be within 0.00001 of each other.
This is because the library uses 64 bit floating point values
instead of 32 bit floating point values, which in some cases
changes the values after that point.

The data for the test suite has come from R, specifically the
iris dataset, since there is a high level of familiarity of
that specific dataset among data scientists and statisticians.

The library is also continuously tested every time a change
is made and pushed up to the main repository to ensure that
breaking changes are found quickly.

Documentation for every function does exist including the actual
equation in LaTeX. The written documentation is somewhat sparse,
however it is supplemental to the actual equation.


## Benchmarks:

Currently there has not been a benchmark on a dataset with gigabytes
of data, due to the work being primarily on my laptop, but that is
planned for the somewhat near future.

However, even without the added advantage of using a graphics card
and instead using futhark's c output, we are on pace with R, with it
often outperforming R.

test suite (personal laptop w/ Ryzen 7 PRO 4750U)

* avg 3 (fustal - sequential c)
  * 0.09s
* avg 3 (R)
  * 0.1266s

## Further work

Currently there is still a decent amount of work left before the library
can be a drop in replacement for R or other statistical libraries.
Additionally, the implementation of neural network code has been
more difficult than anticipated due to the sheer number of different
model types to try. At present, the goal is to implement the most
straight forward machine learning algorithm.

While not exactly 'simple' this implementation of GPT in ~50 lines of python
may serve as a good proof of concept for this library:

* https://github.com/jaymody/picoGPT

Additionally, there are other statistical methods that I would like to
implement as well, such as multivariate linear regression and logistic
regression.


GitHub : https://github.com/ehawkvu/fustal
