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

import "lib/github.com/diku-dk/linalg/linalg"

module linalg_f64 = mk_linalg f64

-- FIXME: Make these functions not depend on floating point values -- have them be defined for all types.

let lanczos : [9]f64 =
  [ 0.99999999999980993,
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7 ]

def log_gamma (z_in: f64) : f64 =
  -- Exact known values
  if z_in == 1.0 then 0.0
  else if z_in == 2.0 then 0.0
  else if z_in == 0.5 then f64.log (f64.sqrt f64.pi)
  else
       let g = 7.0

       let use_reflection = z_in < 0.5
       let z = if use_reflection then 1.0 - z_in else z_in
       let z1 = z - 1.0

       let x =
         let (_, acc) =
           loop (i, acc) = (1i64, lanczos[0])
           while i < 9i64 do
           let term = lanczos[i] / (z1 + f64.i64 i)
           in (i + 1i64, acc + term)
         in acc

       let t = z1 + g + 0.5

       let lg =
         0.5 * f64.log (2.0 * f64.pi)
         + (z1 + 0.5) * f64.log t
         - t
         + f64.log x

       in
       if use_reflection then
         f64.log f64.pi
         - f64.log (f64.sin (f64.pi * z_in))
         - lg
       else
         lg

-- log_gamma 1 == 0.0
-- log_gamma 2 == 0.0
-- log_gamma 0.5 == f64.pi |> f64.sqrt |> f64.log

entry log_beta (a: f64) (b: f64) : f64 =
  log_gamma a + log_gamma b - log_gamma (a + b)


-- log_beta 1 1 == 0.0
-- log_beta 1 5 == -1 * f64.log 5
-- log_beta 0.5 0.5 == f64.log f64.pi
-- log_beta 2.3 7.1 == log_beta 7.1 2.3

def betacf (a: f64) (b: f64) (x: f64) : f64 =
  let max_iter = 100i64
  let fpmin = 1e-30

  let qab = a + b
  let qap = a + 1.0
  let qam = a - 1.0

  let d0 =
    let tmp = 1.0 - qab * x / qap
    in if f64.abs tmp < fpmin then fpmin else tmp

  let d0 = 1.0 / d0
  let c0 = 1.0
  let h0 = d0

  let (_, _, h_final, _) =
    loop (c, d, h, m) = (c0, d0, h0, 1i64)
    while m <= max_iter do

    let m2 = 2i64 * m
    let m_f = f64.i64 m
    let m2_f = f64.i64 m2

    let aa1 =
      m_f * (b - m_f) * x /
      ((qam + m2_f) * (a + m2_f))

    let d1 =
      let tmp = 1.0 + aa1 * d
      in if f64.abs tmp < fpmin then fpmin else tmp

    let c1 =
      let tmp = 1.0 + aa1 / c
      in if f64.abs tmp < fpmin then fpmin else tmp

    let d1 = 1.0 / d1
    let h1 = h * d1 * c1

    let aa2 =
      -(a + m_f) * (qab + m_f) * x /
       ((a + m2_f) * (qap + m2_f))

    let d2 =
      let tmp = 1.0 + aa2 * d1
      in if f64.abs tmp < fpmin then fpmin else tmp

    let c2 =
      let tmp = 1.0 + aa2 / c1
      in if f64.abs tmp < fpmin then fpmin else tmp

    let d2 = 1.0 / d2
    let h2 = h1 * d2 * c2

    in (c2, d2, h2, m + 1i64)

  in h_final

entry regularized_beta (a: f64) (b: f64) (x_in: f64) : f64 =
  if x_in <= 0.0 then 0.0
  else if x_in >= 1.0 then 1.0
  else
       let eps = 1e-15
       let x =
         if x_in < eps then eps
         else if x_in > 1.0 - eps then 1.0 - eps
         else x_in

       let bt =
         f64.exp (
           log_gamma (a + b)
           - log_gamma a
           - log_gamma b
           + a * f64.log x
           + b * f64.log (1.0 - x)
         )

       in
       if x < (a + 1.0) / (a + b + 2.0) then
         bt * betacf a b x / a
       else
         1.0 - bt * betacf b a (1.0 - x) / b

-- regularized_beta 1 1 0.3  → 0.3
-- regularized_beta 1 1 0.7  → 0.7
-- Tolerance: ~1e-14.
-- If this fails → betacf is wrong.

-- regularized_beta 2.3 5.1 0.4
-- 1 - regularized_beta 5.1 2.3 0.6

-- regularized_beta 2.3 5.1 0.0  → 0
-- regularized_beta 2.3 5.1 1.0  → 1

def regularized_gamma (s: f64) (z: f64) : f64 =
  let max_iter = 100i64
  let fpmin = 1e-30
  in if z <= 0.0 then
       0.0

     else if z < s + 1.0 then
       -- Series expansion
       let (_, sum, _) =
         loop (n, acc, term) = (0i64, 1.0 / s, 1.0 / s)
         while n < max_iter do
         let n1 = n + 1i64
         let term1 = term * z / (s + f64.i64 n1)
         in (n1, acc + term1, term1)
       in sum * f64.exp(-z + s * f64.log z - log_gamma s)
     else
       -- Continued fraction
       let (_, _, _, h) =
         loop (i, c, d, h) =
           (1i64,
            1.0 / fpmin,
            1.0 / (z - s + 1.0),
            1.0 / (z - s + 1.0))
         while i < max_iter do

         let i_f = f64.i64 i
         let an = -i_f * (i_f - s)
         let b = z + 2.0 * i_f - s

         let d1 =
           let tmp = an * d + b
           in if f64.abs tmp < fpmin then fpmin else tmp

         let c1 =
           let tmp = b + an / c
           in if f64.abs tmp < fpmin then fpmin else tmp

         let d1 = 1.0 / d1
         let h1 = h * d1 * c1
         in (i + 1i64, c1, d1, h1)
       in
       1.0 - f64.exp(-z + s * f64.log z - log_gamma s) * h

entry student_t_cdf (t: f64) (nu: f64) : f64 =
  let x = nu / (t * t + nu)
  let ib = regularized_beta (nu / 2.0) 0.5 x
  in
  if t >= 0.0 then
    1.0 - 0.5 * ib
  else
    0.5 * ib

-- student_t_cdf 0 5
-- student_t_cdf 0 100

entry student_t_pvalue (t: f64) (nu: f64) : f64 =
  2.0 * (1.0 - student_t_cdf (f64.abs t) nu)

def student_t_quantile (p: f64) (df: f64) : f64 =
  -- Newton iteration
  let max_iter = 30i64
  -- let eps = 1e-12

  let initial =
    if p < 0.5 then -1.0 else 1.0

  let (_, q) =
    loop (i, x) = (0i64, initial)
    while i < max_iter do
    let fx = student_t_cdf x df - p
    let pdf =
      let num = f64.exp(log_gamma((df+1.0)/2.0)
                        - log_gamma(df/2.0))
      let denom =
        f64.sqrt(df * f64.pi)
        * ((1.0 + (x*x)/df) ** ((df+1.0)/2.0))
      in num / denom
    let x1 = x - fx / pdf
    in (i+1i64, x1)
  in q

entry chi_square_cdf (x: f64) (k: f64) : f64 =
  regularized_gamma (k / 2.0) (x / 2.0)

entry chi_square_pvalue (x: f64) (k: f64) : f64 =
  1.0 - chi_square_cdf x k

entry f_cdf (x: f64) (d1: f64) (d2: f64) : f64 =
  regularized_beta
  (d1/2.0)
  (d2/2.0)
  ((d1 * x) / (d1 * x + d2))

entry f_pvalue (x: f64) (d1: f64) (d2: f64) : f64 =
  1.0 - f_cdf x d1 d2

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
  let (_, m2, n) =
    loop (mean_acc, m2_acc, k) = (0.0, 0.0, 0i64) for x in xs do
    let k1 = k + 1
    let delta = x - mean_acc
    let mean_new = mean_acc + delta / f64.i64 k1
    let m2_new = m2_acc + delta * (x - mean_new)
    in (mean_new, m2_new, k1)
  in m2 / f64.i64 n

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

def one_sample_summary (xs: []f64) : (f64, f64, f64, f64) =
  let n_i = length xs
  let n = f64.i64 n_i
  let mean_x = mean xs
  let sd = sample_std xs
  let se = sd / f64.sqrt n
  in (mean_x, sd, se, n)

entry one_sample_mean_ci (xs: []f64) (alpha: f64) : (f64, f64) =
  let (mean_x, _, se, n) = one_sample_summary xs
  let df = n - 1.0
  let tcrit =
    student_t_quantile (1.0 - alpha/2.0) df

  let margin = tcrit * se

  in (mean_x - margin,
      mean_x + margin)

-- one_sample_mean_ci [2,4,6,8,10] 0.05
-- should equal: t.test(c(2,4,6,8,10))$conf.int (in R)

-- desc: Calculate the t statistic for $xs$ when compared against mean $\mu$.
-- equation: $t = \frac{\bar{x} - \mu_0}{s/\sqrt{n}}$
-- link: https://en.wikipedia.org/wiki/Student%27s_t-test#One-sample_t-test
entry one_sample_t_test (xs: []f64) (mu: f64) : f64 =
  let xbar = mean xs in
  let sd = sample_std xs in
  let n = (f64.i64 (length xs)) in
  (xbar - mu) / (sd / f64.sqrt n)

entry one_sample_t_test_full (xs: []f64) (mu0: f64) : (f64, f64, f64, f64) =
  let (mean_x, _, se, n) = one_sample_summary xs
  let df = n - 1.0
  let t = (mean_x - mu0) / se
  let p = student_t_pvalue t df
  in (t, df, p, se)

-- desc: Calculate the t statistic between $as$ and $bs$.
-- equation: $t = \frac{\Delta \bar{X}}{s_{\Delta \bar{X}}} = \frac{\bar{X_1} - \bar{X_2}}{\sqrt{{s_{\bar{X_1}}}^2 + {s_{\bar{X_2}}}^2}}$
-- link: https://en.wikipedia.org/wiki/Welch%27s_t-test
entry two_sample_t_test (as: []f64) (bs: []f64) : f64 =
  let xbar1 = mean as in
  let xbar2 = mean bs in
  let delta_xbar = xbar1 - xbar2 in
  let denom = f64.sqrt (sq (sample_stderr as) + sq (sample_stderr bs)) in
  delta_xbar / denom

entry paired_t_test (xs: []f64) (ys: []f64) : f64 =
  let ds = map2 (-) xs ys in
  let dbar = mean ds in
  let sd = sample_std ds in
  let n = f64.i64 (length ds) in
  dbar / (sd / f64.sqrt n)

entry paired_t_test_full (xs: []f64) (ys: []f64) : (f64, f64, f64) =
  let t = paired_t_test xs ys
  let n = f64.i64 (length xs)
  let df = n - 1.0
  let p = student_t_pvalue t df
  in (t, df, p)


entry welch_df (as: []f64) (bs: []f64) : f64 =
  let n1 = f64.i64 (length as) in
  let n2 = f64.i64 (length bs) in
  let s1 = sample_std as in
  let s2 = sample_std bs in
  let v1 = sq s1 / n1 in
  let v2 = sq s2 / n2 in
  let num = sq (v1 + v2) in
  let denom =
    (sq v1) / (n1 - 1.0) +
    (sq v2) / (n2 - 1.0) in
  num / denom

entry welch_t_test_full (xs: []f64) (ys: []f64) : (f64, f64, f64) =
  let t = two_sample_t_test xs ys
  let df = welch_df xs ys
  let p = student_t_pvalue t df
  in (t, df, p)

entry cohens_d (as: []f64) (bs: []f64) : f64 =
  let n1 = f64.i64 (length as) in
  let n2 = f64.i64 (length bs) in
  let s1 = sample_std as in
  let s2 = sample_std bs in
  let pooled =
    f64.sqrt (
      ((n1 - 1.0) * sq s1 + (n2 - 1.0) * sq s2)
      /
      (n1 + n2 - 2.0)
    )
  in
  (mean as - mean bs) / pooled

entry sample_covariance_matrix (X: [][]f64) : [][]f64 =
  let n = f64.i64 (length X) in
  let means = map mean (transpose X) in
  let Xc =
    map (\row ->
           map2 (\x m -> x - m) row means)
        X in
  let XtX = linalg_f64.matmul (transpose Xc) Xc
  in map (map (\v -> v / (n - 1.0))) XtX

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

entry one_way_anova (groups: [][]f64)
  : (f64, f64, f64, f64, f64, f64, f64, f64, f64) =
  -- returns:
  -- (SS_between, SS_within,
  --  df_between, df_within,
  --  F, p_value, MS_within)

  let K = length groups
  let nV = map length groups
  let N = i64.sum nV

  let means = map mean groups
  let grand_mean =
    (map f64.sum groups |> f64.sum)
    / f64.i64 N

  -- Between-group SS
  let ss_between =
    map2 (\ni mi ->
            f64.i64 ni * sq (mi - grand_mean))
         nV means
    |> f64.sum

  -- Within-group SS
  let ss_within =
    map2 (\grp mi ->
            map (\x -> sq (x - mi)) grp
            |> f64.sum)
         groups means
    |> f64.sum

  let ss_total = ss_between + ss_within

  let df_between = f64.i64 (K - 1)
  let df_within  = f64.i64 (N - K)

  let ms_between = ss_between / df_between
  let ms_within  = ss_within / df_within

  let F = ms_between / ms_within
  let p = f_pvalue F df_between df_within

  in (ss_between, df_between, ms_between,
      ss_within,  df_within,  ms_within,
      ss_total,   F,          p)

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

entry simple_r_squared (xs: []f64) (ys: []f64) : f64 =
  let (a, b) = simple_linear_regression xs ys in
  let yhat = map (\x -> a + b * x) xs in
  let rss = map2 (\y yh -> sq (y - yh)) ys yhat |> f64.sum in
  let ybar = mean ys in
  let tss = map (\y -> sq (y - ybar)) ys |> f64.sum in
  1.0 - (rss / tss)

entry simple_regression_summary (xs: []f64) (ys: []f64)
  : (f64, f64, f64, f64, f64, f64,
     f64, f64, f64, f64, f64, f64) =
  -- returns:
  -- (alpha, beta,
  --  se_alpha, se_beta,
  --  t_alpha, t_beta,
  --  r2, adj_r2)

  let n = f64.i64 (length xs)
  let df = n - 2.0

  let (a, b) =
    simple_linear_regression xs ys

  let yhat =
    map (\x -> a + b*x) xs

  let residuals =
    map2 (-) ys yhat

  let rss =
    map sq residuals
    |> f64.sum

  let sigma2 = rss / df

  let xbar = mean xs
  let sxx =
    map (\x -> sq (x - xbar)) xs
    |> f64.sum

  let se_beta =
    f64.sqrt (sigma2 / sxx)

  let se_alpha =
    f64.sqrt (sigma2 *
              (1.0/n + sq xbar / sxx))

  let t_beta = b / se_beta
  let t_alpha = a / se_alpha

  let p_beta =
    student_t_pvalue t_beta df

  let p_alpha =
    student_t_pvalue t_alpha df

  let r2 =
    simple_r_squared xs ys

  let adj_r2 =
    1.0 - (1.0 - r2) *
          ((n - 1.0) / df)

  -- F-statistic (1 predictor)
  let F =
    (r2 / (1.0 - r2)) * df

  let p_F =
    f_pvalue F 1.0 df

  in (a, b,
      se_alpha, se_beta,
      t_alpha, t_beta,
      p_alpha, p_beta,
      r2, adj_r2,
      F, p_F)

-- link: https://en.wikipedia.org/wiki/Linear_regression#Simple_and_multiple_linear_regression

-- link: https://en.wikipedia.org/wiki/General_linear_model

-- desc:
-- equation: $U = \sum_{i=1}^n\sum_{j=1}^m S(X_i, Y_j), S(X, Y) = \begin{cases}  1 & X > Y \\ \frac{1}{2} & X = Y\\ 0 & X < Y \end{cases}$
-- link: https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
entry wilcoxon_rank_sum_test (xs: []f64) (ys: []f64) : f64 =
  let S = \x y ->
            if x > y then 1.0
            else if x < y then 0.0
            else 0.5
  in
  map (\x -> map (\y -> S x y) ys |> f64.sum)
      xs
  |> f64.sum

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

entry multiple_regression_summary
  (X: [][]f64)  -- must include intercept column
  (y: []f64)
  : ( []f64,    -- coefficients
      []f64,    -- std errors
      []f64,    -- t values
      []f64,    -- p values
      f64,      -- r2
      f64,      -- adj r2
      f64,      -- F
      f64 ) =   -- F p-value

  let n = f64.i64 (length y)
  let p = f64.i64 (length (X[0]))

  let Xt = transpose X
  let XtX = linalg_f64.matmul Xt X
  let XtX_inv = linalg_f64.inv XtX
  let XtY = linalg_f64.matvecmul_row Xt y
  let beta = linalg_f64.matvecmul_row XtX_inv XtY

  let yhat =
    linalg_f64.matvecmul_row X beta

  let residuals =
    map2 (-) y yhat

  let rss =
    map sq residuals |> f64.sum

  let ybar = mean y
  let tss =
    map (\v -> sq (v - ybar)) y |> f64.sum

  let r2 = 1.0 - rss / tss
  let df_model = p - 1.0
  let df_resid = n - p

  let adj_r2 =
    1.0 - (1.0 - r2) *
          ((n - 1.0) / df_resid)

  let sigma2 = rss / df_resid

  let cov_beta =
    linalg_f64.matscale sigma2 XtX_inv

  let se =
    linalg_f64.fromdiag cov_beta
    |> map f64.sqrt

  let tvals =
    map2 (/) beta se

  let pvals =
    map (\t -> student_t_pvalue t df_resid)
        tvals

  let ms_model =
    (tss - rss) / df_model

  let ms_resid =
    rss / df_resid

  let F = ms_model / ms_resid
  let p_F = f_pvalue F df_model df_resid

  in (beta,
      se,
      tvals,
      pvals,
      r2,
      adj_r2,
      F,
      p_F)

-- [[2,4,5,4,5], [1,2,3,4,5], [5,4,3,2,1]]

-- multiple_regression_summary [[1,1,5], [1,2,4], [1,3,3], [1,4,2], [1,5,1]] [2,4,5,4,5]

entry covariance_matrix (X: [][]f64) : [][]f64 =
  let Xc =
    let means = map mean (transpose X) in
    map (\row ->
           map2 (\x m -> x - m) row means)
        X
  let n = f64.i64 (length X) in
  linalg_f64.matmul (transpose Xc) Xc
  |> map (map (\v -> v / (n - 1)))

def back_substitute [n] (R: [n][n]f64) (b: [n]f64) (rank: i64) : [n]f64 =
  let beta = replicate n 0.0
  in
  loop beta = beta for i in (rank-1)..>-1 do
  let rhs =
    if i+1 < rank then
      b[i] -
      (map2 (*) R[i][i+1:rank] beta[i+1:rank]
       |> f64.sum)
    else b[i]
  let xi =
    if f64.abs R[i][i] < 1e-12 then f64.nan
    else rhs / R[i][i]
  in beta with [i] = xi

def qr_regression_solve [m][n]
  (X_in: [m][n]f64)
  (y_in: [m]f64)
  : ([n]f64, i64, [m][n]f64) =
  -- def qr_regression_solve (X_in: [][]f64) (y_in: []f64)
  --   : ([]f64, i64, [][]f64) =
  -- returns:
  -- (beta, rank, R)

  let X = copy X_in
  let y = copy y_in


  let (X, y, rank) =
    loop (X, y, rnk) = (X, y, 0i64)
    for k in 0..<n do

      -- extract column vector
      let x =
        map (\row -> row[k])
            X[k:m]

      let normx =
        f64.sqrt (map sq x |> f64.sum)

      let sign =
        if x[0] >= 0.0 then 1.0 else -1.0

      let alpha = -sign * normx

      let v =
        x with [0] = x[0] - alpha

      let vnorm =
        map sq v |> f64.sum

      let beta =
        if vnorm < 1e-20 then 0.0
        else 2.0 / vnorm

      let X =
        if beta == 0.0 then X
        else
        let Xt_v =
          map (\j ->
                 map2 (*)
                      v
                      (map (\row -> row[j])
                           X[k:m])
                 |> f64.sum)
              (iota n)
        in
        tabulate m (\i ->
                      tabulate n (\j ->
                                    if i < k then
                                      X[i][j]
                                    else
                                    let vi = v[i-k]
                                    in X[i][j] - beta * vi * Xt_v[j]))

      let y =
        if beta == 0.0 then y
        else
        let vt_y =
          map2 (*) v y[k:m] |> f64.sum

        in
        tabulate m (\i ->
                      if i < k then y[i]
                      else
                        y[i] - beta * v[i-k] * vt_y)

      let diag =
        if k < m then f64.abs X[k][k] else 0.0

      let rnk =
        if diag > 1e-10 then rnk + 1 else rnk

      in (X, y, rnk)

  let R =
    tabulate m (\i ->
                  tabulate n (\j ->
                                X[i][j]))
  let Qt_y = y

  let R_upper =
    tabulate n (\i ->
                  tabulate n (\j ->
                                R[i][j]))

  let y_upper =
    Qt_y[0:n]

  let beta =
    back_substitute R_upper y_upper rank

  in (beta, rank, R)


entry multiple_regression_summary_qr [m][n]
  (X: [m][n]f64)
  (y: [m]f64)
  : ([]f64, []f64, []f64, []f64,
     f64, f64, f64, f64,
     f64,
     []f64,
     []f64,
     [][]f64,
     []f64,
     []f64,
     []f64) =

  let n_obs = f64.i64 (length y)

  let (beta_raw, rank_i, R) =
    qr_regression_solve X y

  let beta_masked =
    tabulate n (\i ->
                  if i < rank_i then
                    beta_raw[i]
                  else
                    f64.nan)


  let rank = f64.i64 rank_i
  let df_model = rank - 1.0
  let df_resid = n_obs - rank

  let yhat =
    linalg_f64.matvecmul_row X beta_raw

  let residuals =
    map2 (-) y yhat

  let rss =
    map sq residuals |> f64.sum

  let ybar = mean y
  let tss =
    map (\v -> sq (v - ybar)) y |> f64.sum

  let r2 = 1.0 - rss / tss

  let adj_r2 =
    1.0 - (1.0 - r2) *
          ((n_obs - 1.0) / df_resid)

  let sigma2 = rss / df_resid
  let rse = f64.sqrt sigma2

  let R1 =
    tabulate rank_i (\i ->
                       tabulate rank_i (\j ->
                                          R[i][j]))

  let Rinv =
    linalg_f64.inv R1

  let cov_beta_small =
    linalg_f64.matscale sigma2
                        (linalg_f64.matmul Rinv (transpose Rinv))

  let XtX_inv =
    linalg_f64.matscale (1.0 / sigma2) cov_beta_small

  let leverage =
    tabulate m (\i ->
                  if rank_i == 0 then
                    0.0
                  else
                  let xi =
                    X[i][0:rank_i]
                  let tmp =
                    linalg_f64.matvecmul_row XtX_inv xi
                  in
                  linalg_f64.dotprod xi tmp)

  let std_resid =
    tabulate m (\i ->
                  let denom =
                    rse * f64.sqrt (1.0 - leverage[i])
                  in
                  if denom <= 0.0 then
                    f64.nan
                  else
                    residuals[i] / denom)

  let p_model = f64.i64 rank_i

  let cooks =
    tabulate m (\i ->
                  let denom =
                    p_model * sigma2 * (1.0 - leverage[i]) * (1.0 - leverage[i])
                  in
                  if denom <= 0.0 then
                    f64.nan
                  else
                    (sq residuals[i]) * leverage[i] / denom)

  let se_small =
    linalg_f64.fromdiag cov_beta_small
    |> map f64.sqrt

  let se =
    tabulate n (\i ->
                  if i < rank_i then
                    se_small[i]
                  else
                    f64.nan)

  let tcrit =
    student_t_quantile 0.975 df_resid

  let conf_int =
    tabulate n (\i ->
                  if i < rank_i then
                    [ beta_raw[i] - tcrit * se[i],
                      beta_raw[i] + tcrit * se[i] ]
                  else
                    [f64.nan, f64.nan])

  let tvals =
    map2 (/) beta_raw se

  let pvals =
    map (\t ->
           if f64.isnan t then f64.nan
           else student_t_pvalue t df_resid)
        tvals

  let ms_model =
    (tss - rss) / df_model

  let ms_resid =
    rss / df_resid

  let F = ms_model / ms_resid
  let p_F = f_pvalue F df_model df_resid

  in (beta_masked, se, tvals, pvals,
      r2, adj_r2, F, p_F,
      rse,
      yhat,
      residuals,
      conf_int,
      leverage,
      std_resid,
      cooks)

-- multiple_regression_summary_qr [[1,1], [1,2], [1,3], [1,4], [1,5]] [2,4,5,4,5]
-- multiple_regression_summary_qr [[1,1,5], [1,2,4], [1,3,3], [1,4,2], [1,5,1]] [2,4,5,4,5]


def sigmoid (x: f64) : f64 =
  if x >= 0.0 then
  let z = f64.exp (-x)
  in 1.0 / (1.0 + z)
  else
  let z = f64.exp x
  in z / (1.0 + z)


def logistic_loglik (y: []f64) (p: []f64) : f64 =
  let eps = 1e-15
  let p_clamped =
    map (\pi ->
           if pi < eps then eps
           else if pi > 1.0 - eps then 1.0 - eps
           else pi)
        p
  in
  map2 (\yi pi ->
          yi * f64.log pi +
          (1.0 - yi) * f64.log (1.0 - pi))
       y p_clamped
  |> f64.sum


def irls_step [m][n]
  (X: [m][n]f64)
  (y: [m]f64)
  (beta: [n]f64)
  : ([n]f64, [m]f64, [m]f64) =

  let eta =
    linalg_f64.matvecmul_row X beta

  let p =
    map sigmoid eta

  let eps = 1e-12
  let W =
    map (\pi ->
           let w = pi * (1.0 - pi)
           in if w < eps then eps else w)
        p

  let z =
    tabulate m (\i ->
                  eta[i] + (y[i] - p[i]) / W[i]
               )

  -- weighted X and z
  let sqrtW =
    map f64.sqrt W

  let Xw =
    tabulate m (\i ->
                  tabulate n (\j ->
                                X[i][j] * sqrtW[i]))

  let zw =
    map2 (*) z sqrtW

  let (beta_new, _, _) =
    qr_regression_solve Xw zw

  in (beta_new, p, W)


entry logistic_regression_fit_qr [m][n]
  (X: [m][n]f64)
  (y: [m]f64)
  : ([n]f64, [m]f64, f64) =

  let max_iter = 25i64
  let tol = 1e-8

  let beta0 =
    replicate n 0.0
  let (beta, p, _, _) =
    loop (beta, _, iter, diff) =
      (beta0, replicate m 0.5, 0i64, 1.0)
    while iter < max_iter && diff > tol do

    let (beta_new, p_new, _) =
      irls_step X y beta

    let diff_new =
      map2 (\a b -> f64.abs (a-b))
           beta_new beta
      |> f64.sum

    in (beta_new,
        p_new,
        iter + 1i64,
        diff_new)

  let loglik =
    logistic_loglik y p

  in (beta, p, loglik)

entry logistic_regression_summary_qr [m][n]
  (X: [m][n]f64)
  (y: [m]f64)
  : ([]f64, []f64, []f64, []f64, f64,
     f64,
     f64,
     f64,
     f64) =

  let (beta, p, loglik) =
    logistic_regression_fit_qr X y

  let rank = f64.i64 (length beta)

  let deviance =
    -2.0 * loglik

  let ybar = mean y
  let p_null =
    replicate m ybar

  let loglik_null =
    logistic_loglik y p_null

  let null_deviance =
    -2.0 * loglik_null

  let aic =
    deviance + 2.0 * rank

  let pseudo_r2 =
    1.0 - (loglik / loglik_null)

  let W =
    map (\pi -> pi * (1.0 - pi)) p

  let sqrtW =
    map f64.sqrt W

  let Xw =
    tabulate m (\i ->
                  tabulate n (\j ->
                                X[i][j] * sqrtW[i]))

  let Xt = transpose Xw
  let XtX = linalg_f64.matmul Xt Xw
  let XtX_inv = linalg_f64.inv XtX

  let se =
    linalg_f64.fromdiag XtX_inv
    |> map f64.sqrt

  let zvals =
    map2 (/) beta se

  let pvals =
    map (\z ->
           2.0 * (1.0 - student_t_cdf (f64.abs z) 1e6))
        zvals

  in (beta, se, zvals, pvals,
      loglik,
      deviance,
      null_deviance,
      aic,
      pseudo_r2)

-- logistic_regression_summary_qr [[1.0, 0.0], [1.0, 1.0], [1.0, 2.0], [1.0, 3.0], [1.0, 4.0]] [0.0, 0.0, 0.0, 1.0, 1.0]
-- logistic_regression_summary_qr [[1.0, 0.0], [1.0, 1.0], [1.0, 2.0], [1.0, 3.0], [1.0, 4.0], [1.0, 5.0]] [0.0, 0.0, 1.0, 0.0, 1.0, 1.0]


-- x <- c(0,1,2,3,4,5)
-- y <- c(0,0,1,0,1,1)
-- summary(glm(y ~ x, family=binomial))
