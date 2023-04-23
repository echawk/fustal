timer <- function(quoted_code) {
    start.time <- Sys.time()
    v <- eval(quoted_code)
    end.time <- Sys.time()
    time.taken = end.time - start.time
    as.vector(c(time.taken, v))
}
# Prevent Scientific notation.
options(scipen=999)
data("iris")

"sample_var"
timer(quote(var(iris$Sepal.Length)))
"sample_std"
timer(quote(sd(iris$Sepal.Length)))
"sample_stderr"
timer(quote(sd(iris$Sepal.Length) / sqrt(length(iris$Sepal.Length))))
"one_sample_t_test"
timer(quote(t.test(iris$Sepal.Length, mu = 6)$statistic[["t"]]))
"two_sample_t_test"
timer(quote(t.test(iris$Sepal.Length, iris$Sepal.Width)$statistic[["t"]]))
"pearson_correlation_coefficient"
timer(quote(cor(iris$Sepal.Length, iris$Sepal.Width)))
"simple_linear_regression"
timer(quote(as.vector(coefficients(lm(Sepal.Width ~ Sepal.Length, data=iris)))))
"f_test"
timer(quote(as.vector(anova(aov(Sepal.Length ~ Species, data=iris))$"F value")[1]))
chisq_data <- matrix(c(120, 90, 40, 110, 95, 45), ncol=3, byrow=TRUE)
"chi_squared_test"
timer(quote(as.vector(chisq.test(chisq_data)$statistic)))
#"wilcoxon_rank_sum_test"
#as.vector(wilcox.test(iris$Sepal.Length, iris$Sepal.Width)$statistic)
