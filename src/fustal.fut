
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
                               
entry variance (xs: []f64) : f64 =
  mean (map (\x -> (f64.abs (sq (x - (mean xs))))) xs)
                
entry stddev (xs: []f64) : f64 =
  f64.sqrt (variance xs)

--def median (xs: []f64)
--def mode (xs: []f64)
                                                              
--entry main = average [1.2, 2.3, 3.4, 4.5, 5.6, 6.7]
