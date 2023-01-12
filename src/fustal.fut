
-- Reference: https://docs.python.org/3/library/statistics.html

--
-- mean, fmean, geometric_mean, harmonic_mean
-- median, median_low, median_high, median_grouped
-- mode, mutlimode
-- quantiles

-- FIXME: Make these functions not depend on floating point values -- have them be defined for all types.

entry mean (xs: []f64) : f64 =
  (f64.sum xs) / f64.i64 (length xs)

entry sq (x: f64) : f64 =
  x * x

entry var (xs: []f64) : f64 =
  mean (map (\x -> (f64.abs (sq (x - (mean xs))))) xs)

entry std (xs: []f64) : f64 =
  f64.sqrt (var xs)

-- FIXME: doesn't seem to be correct.
entry sample_std (xs: []f64) : f64 =
  f64.sqrt (f64.sum (map (\x -> (f64.abs (sq (x - (mean xs))))) xs))

-- https://en.wikipedia.org/wiki/Standard_error
entry stderr (xs: []f64) : f64 =
  let sd = std xs in
  let denom = f64.sqrt (f64.i64 (length xs)) in
  sd / denom


-- FIXME: seems to be slightly off (when compared to R on the iris SepalLength data)
entry one_sample_t_test(xs: []f64) (mu: f64) : f64 =
  let xbar = mean xs in
  let sd = std xs in
  let n = (f64.i64 (length xs)) in
  (xbar - mu) / (sd / f64.sqrt n)


--def median (xs: []f64)
--def mode (xs: []f64)
