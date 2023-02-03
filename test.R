data("iris")

s <- sd(iris$Sepal.Length)
var(iris$Sepal.Length)
s
s / sqrt(length(iris$Sepal.Length))
t.test(iris$Sepal.Length, mu = 6)$statistic[["t"]]
t.test(iris$Sepal.Length, iris$Sepal.Width)$statistic[["t"]]
cor(iris$Sepal.Length, iris$Sepal.Width)
anova(aov(Sepal.Length ~ Species, data=iris))
chisq_data <- matrix(c(120, 90, 40, 110, 95, 45), ncol=3, byrow=TRUE)
chisq.test(chisq_data)
