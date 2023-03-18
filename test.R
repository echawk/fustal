data("iris")

s <- sd(iris$Sepal.Length)
"sample_var"
var(iris$Sepal.Length)
"sample_std"
s
"sample_stderr"
s / sqrt(length(iris$Sepal.Length))
"one_sample_t_test"
t.test(iris$Sepal.Length, mu = 6)$statistic[["t"]]
"two_sample_t_test"
t.test(iris$Sepal.Length, iris$Sepal.Width)$statistic[["t"]]
"pearson_correlation_coefficient"
cor(iris$Sepal.Length, iris$Sepal.Width)
"simple_linear_regression"
as.vector(coefficients(lm(Sepal.Width ~ Sepal.Length, data=iris)))
"f_test"
as.vector(anova(aov(Sepal.Length ~ Species, data=iris))$"F value")[1]
chisq_data <- matrix(c(120, 90, 40, 110, 95, 45), ncol=3, byrow=TRUE)
"chi_squared_test"
as.vector(chisq.test(chisq_data)$statistic)
