-- https://en.wikipedia.org/wiki/Pooled_variance
-- https://en.wikipedia.org/wiki/Degrees_of_freedom_(statistics)
-- https://www.indeed.com/career-advice/career-development/how-to-calculate-iqr
-- https://futhark-lang.org/blog/2020-05-03-higher-order-parallel-programming.html
-- https://en.wikipedia.org/wiki/Bias_of_an_estimator
-- https://en.wikipedia.org/wiki/Sample_mean_and_covariance
-- https://github.com/haskell/statistics
-- https://www.indeed.com/career-advice/career-development/calculate-t-score
-- https://www.indeed.com/career-advice/career-development/how-to-calculate-covariance
-- https://en.wikipedia.org/wiki/Covariance
-- https://github.com/diku-dk/sorts
-- https://www.programiz.com/r/dataset
-- https://github.com/diku-dk/statistics/blob/master/lib/github.com/diku-dk/statistics/statistics.fut
-- https://github.com/fzzle/futhark-svm
-- https://futhark-lang.org/student-projects/emil-msc-thesis.pdf
-- https://en.wikipedia.org/wiki/Pearson_correlation_coefficient
-- https://www.geeksforgeeks.org/covariance-and-correlation-in-r-programming/
-- https://github.com/mirror/r/tree/master/src/library/stats/src

-- Reference: https://docs.python.org/3/library/statistics.html

--
-- mean, fmean, geometric_mean, harmonic_mean
-- median, median_low, median_high, median_grouped
-- mode, mutlimode
-- quantiles

-- FIXME: Make these functions not depend on floating point values -- have them be defined for all types.

-- desc:
-- equation: $\mu = \frac{1}{n} \sum_{i=1}^{n}x_i$
-- link:
entry mean (xs: []f64) : f64 =
  (f64.sum xs) / f64.i64 (length xs)

-- desc: Calculate the value of `x` squared.
-- equation: $x^2$
entry sq (x: f64) : f64 =
  x * x

-- desc:
-- equation: $ \sigma^2 = \frac{1}{n} \sum_{i=1}^n(x_i - \mu)^2$
-- link: https://en.wikipedia.org/wiki/Variance
entry var (xs: []f64) : f64 =
  let mu = mean xs in
  mean (map (\x -> (sq (x - mu))) xs)

-- desc:
-- equation: $\sigma = \sqrt{\sigma^2}$
-- link:
entry std (xs: []f64) : f64 =
  f64.sqrt (var xs)

-- desc:
-- equation: $\sqrt{\frac{1}{n - 1} \sum_{i=1}^{n}(x_i - \bar{x})^2}$
-- link: https://en.wikipedia.org/wiki/Standard_deviation#Corrected_sample_standard_deviation
entry sample_std (xs: []f64) : f64 =
  let xbar = mean xs in
  let n = f64.i64 (length xs) in
  f64.sqrt ((f64.sum (map (\x -> (sq (x - xbar))) xs)) / (n - 1))

-- desc:
-- equation: $\sigma_{\bar{x}} = \frac{\sigma}{\sqrt{n}}$
-- link: https://en.wikipedia.org/wiki/Standard_error
entry stderr (xs: []f64) : f64 =
  let sd = std xs in
  let denom = f64.sqrt (f64.i64 (length xs)) in
  sd / denom


-- FIXME: seems to be slightly off (when compared to R on the iris SepalLength & Width data)
-- NOTE: it does pass the assertion test when you run cov(x, x) == var(x)
entry cov (xs: []f64) (ys: []f64) : f64 =
  let mu = mean xs in
  let v = mean ys in
  let n = f64.i64 (length xs) in
  f64.sum (map2 (\x y -> (x - mu) * (y - v)) xs ys) / n

-- desc:
-- equation: $t = \frac{\bar{x} - \mu_0}{s/\sqrt{n}}$
-- link: https://en.wikipedia.org/wiki/Student%27s_t-test#One-sample_t-test
entry one_sample_t_test(xs: []f64) (mu: f64) : f64 =
  let xbar = mean xs in
  let sd = sample_std xs in
  let n = (f64.i64 (length xs)) in
  (xbar - mu) / (sd / f64.sqrt n)


--def median (xs: []f64)
--def mode (xs: []f64)
