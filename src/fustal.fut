-- https://futhark-lang.org/blog/2020-05-03-higher-order-parallel-programming.html
-- https://en.wikipedia.org/wiki/Bias_of_an_estimator
-- https://en.wikipedia.org/wiki/Sample_mean_and_covariance
-- https://github.com/haskell/statistics
-- https://github.com/diku-dk/sorts
-- https://github.com/diku-dk/statistics/blob/master/lib/github.com/diku-dk/statistics/statistics.fut
-- https://github.com/fzzle/futhark-svm
-- https://github.com/mortvest/hastl
-- https://futhark-lang.org/student-projects/emil-msc-thesis.pdf
-- https://www.geeksforgeeks.org/covariance-and-correlation-in-r-programming/
-- https://github.com/mirror/r/tree/master/src/library/stats/src
-- https://en.wikipedia.org/wiki/Analysis_of_variance

--
-- mean, fmean, geometric_mean, harmonic_mean
-- median, median_low, median_high, median_grouped
-- mode, mutlimode
-- quantiles

-- FIXME: linalg upstream is broken due to the use of 'flatten_to'.
-- import "lib/github.com/diku-dk/linalg/linalg"

-- module linalg_f64 = mk_linalg f64

-- FIXME: Make these functions not depend on floating point values -- have them be defined for all types.

-- desc: Calculate the value of $x$ squared.
-- equation: $x^2$
entry sq (x: f64) : f64 =
  x * x

-- desc: Calculate the mean of $xs$.
-- equation: $\mu = \frac{1}{n} \sum_{i=1}^{n}x_i$
-- link:
entry mean (xs: []f64) : f64 =
  (f64.sum xs) / f64.i64 (length xs)

-- desc: Calculate the population Variance for $xs$.
-- equation: $\sigma^2 = \frac{1}{n} \sum_{i=1}^n(x_i - \mu)^2$
-- link: https://en.wikipedia.org/wiki/Variance
entry var (xs: []f64) : f64 =
  let mu = mean xs in
  mean (map (\x -> (sq (x - mu))) xs)

-- desc: Calculate the population standard deviation for $xs$.
-- equation: $\sigma = \sqrt{\sigma^2}$
-- link:
entry std (xs: []f64) : f64 =
  f64.sqrt (var xs)

-- desc: Calculate the population standard error for $xs$.
-- equation: $\sigma_{\bar{x}} = \frac{\sigma}{\sqrt{n}}$
-- link: https://en.wikipedia.org/wiki/Standard_error
entry stderr (xs: []f64) : f64 =
  let sd = std xs in
  let denom = f64.sqrt (f64.i64 (length xs)) in
  sd / denom

-- desc: Calculate the covariance between $xs$ and $ys$.
-- equation: $cov(X, Y) = \frac{1}{n} \sum_{i=1}^n{(x_i - \mu)(y_i - v)}$
entry cov (xs: []f64) (ys: []f64) : f64 =
  let mu = mean xs in
  let v = mean ys in
  mean (map2 (\x y -> (x - mu) * (y - v)) xs ys)

-- desc: Calculate the sample variance for $xs$.
-- equation: $s^2 = \frac{1}{n - 1} \sum_{i=1}^{n}(x_i - \bar{x})^2$
-- link: https://en.wikipedia.org/wiki/Standard_deviation#Corrected_sample_standard_deviation
entry sample_var (xs: []f64) : f64 =
  let xbar = mean xs in
  let n = f64.i64 (length xs) in
  (f64.sum (map (\x -> (sq (x - xbar))) xs)) / (n - 1)

-- desc: Calculate the sample standard deviation for $xs$.
-- equation: $s = \sqrt{s^2}$
-- link: https://en.wikipedia.org/wiki/Standard_deviation#Corrected_sample_standard_deviation
entry sample_std (xs: []f64) : f64 =
  f64.sqrt (sample_var xs)

-- desc: Calculate the sample standard error for $xs$.
-- equation: $se_{\bar{x}} = \frac{s}{\sqrt{n}}$
entry sample_stderr (xs: []f64) : f64 =
  let sd = sample_std xs in
  let denom = f64.sqrt (f64.i64 (length xs)) in
  sd / denom

-- desc: Calculate the sample covariance between $xs$ and $ys$.
-- equation: $cov(X, Y) = \frac{1}{(n - 1)} \sum_{i=1}^n{(x_i - \mu)(y_i - v)}$
-- NOTE: this function is equivalent to R's `cov(x,y)`
entry sample_cov (xs: []f64) (ys: []f64) : f64 =
  let mu = mean xs in
  let v = mean ys in
  let n = f64.i64 (length xs) in
  f64.sum (map2 (\x y -> (x - mu) * (y - v)) xs ys) / (n - 1)

-- desc: Calculate the t statistic for $xs$ when compared against mean $\mu$.
-- equation: $t = \frac{\bar{x} - \mu_0}{s/\sqrt{n}}$
-- link: https://en.wikipedia.org/wiki/Student%27s_t-test#One-sample_t-test
entry one_sample_t_test (xs: []f64) (mu: f64) : f64 =
  let xbar = mean xs in
  let sd = sample_std xs in
  let n = (f64.i64 (length xs)) in
  (xbar - mu) / (sd / f64.sqrt n)

-- desc: Calculate the t statistic between $as$ and $bs$.
-- equation: $t = \frac{\Delta \bar{X}}{s_{\Delta \bar{X}}} = \frac{\bar{X_1} - \bar{X_2}}{\sqrt{{s_{\bar{X_1}}}^2 + {s_{\bar{X_2}}}^2}}$
-- link: https://en.wikipedia.org/wiki/Welch%27s_t-test
entry two_sample_t_test (as: []f64) (bs: []f64) : f64 =
  let xbar1 = mean as in
  let xbar2 = mean bs in
  let delta_xbar = xbar1 - xbar2 in
  let denom = f64.sqrt (sq (sample_stderr as) + sq (sample_stderr bs)) in
  delta_xbar / denom

-- desc: Calculate the pearson correlation coefficient between $xs$ and $ys$.
-- equation: $\rho_{X,Y} = \frac{cov(X, Y)}{\sigma_X \sigma_Y}$
-- link: https://en.wikipedia.org/wiki/Pearson_correlation_coefficient
entry pearson_correlation_coefficient (xs: []f64) (ys: []f64) : f64 =
  let cov_xy = cov xs ys in
  let x_sd = std xs in
  let y_sd = std ys in
  cov_xy / (y_sd * x_sd)

-- desc: Calculates the F-Test statistic for a one-way ANOVA for a matrix $M$, where the rows are the different populations.
-- equation: $F = \frac{\sum_{i=1}^K n_i \frac{(\bar{Y_i} - \bar{Y})^2}{(K - 1)}}{\sum_{i=1}^K\sum_{j=1}^{n_i}\frac{(Y_{ij} - \bar{Y_i})^2}{(N - K)}}$
-- link: https://en.wikipedia.org/wiki/F-test
-- TODO: clean up variable names?
entry f_test (M: [][]f64) : f64 =
  let K = length M in
  let nV = map length M in
  let N = i64.sum nV in
  let ybV = map mean M in
  let yb_num = map f64.sum M |> f64.sum in
  let yb_den = f64.i64 (map length M |> i64.sum) in
  let yb = yb_num / yb_den in
  let exp_var = map (\i -> (f64.i64 nV[i]) * ((sq ((ybV[i]) - yb)) /
                                              (f64.i64 (K - 1))))
                    (iota K) |> f64.sum in
  let f = \i -> f64.sum
                (map (\yij -> (sq (yij - ybV[i])) /
                              (f64.i64 (N - K))) M[i]) in
  let une_var = map f (iota K) |> f64.sum in
  exp_var / une_var

--desc: Convert i64 matrices into f64 matrices.
def Mf64_Mi64 (iM: [][]i64) : [][]f64 =
  map (\r ->
         (map (\v -> f64.i64 v)) r)
      iM

-- let m = [[120, 90, 40],[110,95,45]] : [][]i64
-- chi_squared_test(m)
-- desc: Computes the $\chi^2$ statistic for a matrix $M$, where the rows and columns are different categories.
-- equation: $\chi^2 = \sum_{i=1}^k\frac{(O_i - E_i)^2}{E_i}$
-- link: https://en.wikipedia.org/wiki/Chi-squared_test
entry chi_squared_test (M: [][]i64) : f64 =
  let fM = Mf64_Mi64 M in
  let rowTotals = map f64.sum fM in
  let colTotals = transpose fM |> map f64.sum in
  let obvTotal = f64.sum rowTotals in
  -- (row * col) / n
  let expM = map (\rt -> map (\ct -> rt * ct / obvTotal)
                             colTotals)
                 rowTotals in
  map2 (\or er ->
          map2 (\ov ev -> (sq (ov - ev)) / ev)
               or er)
       fM expM
       |> map f64.sum
              |> f64.sum

-- desc: Calculates the $\hat{\alpha}$ and $\hat{\beta}$ values for a simple linear regression model for $xs$ and $ys$.
-- equation: $(\hat{\alpha}, \hat{\beta}) = (\bar{y} - (\hat{\beta} - \bar{x}), \frac{\sum_{i = 1}^n(x_i - \bar{x})(y_i - \bar{y})}{\sum_{i = 1}^n (x_i - \bar{x})^2})$
-- link: https://en.wikipedia.org/wiki/Simple_linear_regression
entry simple_linear_regression (xs: []f64) (ys: []f64) : (f64, f64) =
  let xbar = mean xs in
  let ybar = mean ys in
  let beta_hat = (map2 (\xi yi -> (xi - xbar) * (yi - ybar))
                       xs ys |> f64.sum) /
                 (map (\xi -> sq (xi - xbar))
                      xs |> f64.sum) in
  let alpha_hat = ybar - (beta_hat * xbar) in
  (alpha_hat, beta_hat)

-- link: https://en.wikipedia.org/wiki/Linear_regression#Simple_and_multiple_linear_regression

-- link: https://en.wikipedia.org/wiki/General_linear_model

-- desc:
-- equation: $U = \sum_{i=1}^n\sum_{j=1}^m S(X_i, Y_j), S(X, Y) = \begin{cases}  1 & X > Y \\ \frac{1}{2} & X = Y\\ 0 & X < Y \end{cases}$
-- link: https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
-- FIXME: this is the wrong computation? (see wilcox.test() in R)
-- https://github.com/mirror/r/blob/master/src/library/stats/R/wilcox.test.R#L73
entry wilcoxon_rank_sum_test (xs: []f64) (ys: []f64) : f64 =
  let S =
    \x y -> if x > y then 1
            else
            if x < y then 0
       else 0.5
            in
  map2 S xs ys |> f64.sum

-- https://en.wikipedia.org/wiki/Two-way_analysis_of_variance

-- https://en.wikipedia.org/wiki/Tukey%27s_range_test

-- link: https://en.wikipedia.org/wiki/Logistic_regression

-- https://towardsdatascience.com/multiple-linear-regression-from-scratch-in-numpy-36a3e8ac8014
-- https://www.statology.org/multiple-linear-regression-r/
-- https://www.statology.org/multiple-linear-regression/
-- https://github.com/diku-dk/linalg
-- https://brilliant.org/wiki/multivariate-regression/#multiple-regression
-- B^ = (XT * X)^-1 * (XT*Y)

-- let xs = [[10, 20],[20, 0]] : [][]f64
-- let ys = [50, 20] : []f64
-- entry multiple_linear_regression (xs: [][]f64) (ys: []f64) : [][]f64 =
--   let xsT = transpose xs in
--   let xsTxsI = linalg_f64.matmul xsT xs |> linalg_f64.inv in
--   let xsTys = linalg_f64.matvecmul_col xsT ys in
--   linalg_f64.matmul xsTxsI xsTys
  --1.0
