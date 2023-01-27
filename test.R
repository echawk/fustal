data("iris")

t.test(iris$Sepal.Length, mu = 6)
t.test(iris$Sepal.Length, iris$Sepal.Width)

sd(iris$Sepal.Length)
var(iris$Sepal.Length)
mean(iris$Sepal.Length)

cov(iris$Sepal.Length, iris$Sepal.Width)
cov(iris$Sepal.Length, iris$Sepal.Length)
cor(iris$Sepal.Length, iris$Sepal.Width)
