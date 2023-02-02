data("iris")

s <- sd(iris$Sepal.Length)
var(iris$Sepal.Length)
s
s / sqrt(length(iris$Sepal.Length))
t.test(iris$Sepal.Length, mu = 6)$statistic[["t"]]
t.test(iris$Sepal.Length, iris$Sepal.Width)$statistic[["t"]]
cor(iris$Sepal.Length, iris$Sepal.Width)
summary(aov(Sepal.Length ~ Species, data=iris))
