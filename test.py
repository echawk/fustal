#!/usr/bin/python3

import numpy as np

import _fustal
from futhark_ffi import Futhark
fustal = Futhark(_fustal)

data = np.array([20000.0,18000.0,20400.0,21050.0,23000.0,22300.0])

print("numpy---")
for func in [np.mean, np.var, np.std]:
    print(f"{func.__name__}: ", func(data))

print("fustal---")
for func in [fustal.mean, fustal.var, fustal.std]:
    print(f"{func.__name__}: ", func(data))

print("Stderr---")
print("Fustal: ", fustal.stderr(data))
print("Numpy: ", np.std(data) / np.sqrt(np.size(data)))

# data("iris"); print(iris$Sepal.Length)
data = np.array([5.1,4.9,4.7,4.6,5,5.4,4.6,5,4.4,4.9,5.4,4.8,4.8,4.3,5.8,5.7,5.4,5.1,5.7,5.1,5.4,5.1,4.6,5.1,4.8,5,5,5.2,5.2,4.7,4.8,5.4,5.2,5.5,4.9,5,5.5,4.9,4.4,5.1,5,4.5,4.4,5,5.1,4.8,5.1,4.6,5.3,5,7,6.4,6.9,5.5,6.5,5.7,6.3,4.9,6.6,5.2,5,5.9,6,6.1,5.6,6.7,5.6,5.8,6.2,5.6,5.9,6.1,6.3,6.1,6.4,6.6,6.8,6.7,6,5.7,5.5,5.5,5.8,6,5.4,6,6.7,6.3,5.6,5.5,5.5,6.1,5.8,5,5.6,5.7,5.7,6.2,5.1,5.7,6.3,5.8,7.1,6.3,6.5,7.6,4.9,7.3,6.7,7.2,6.5,6.4,6.8,5.7,5.8,6.4,6.5,7.7,7.7,6,6.9,5.6,7.7,6.3,6.7,7.2,6.2,6.1,6.4,7.2,7.4,7.9,6.4,6.3,6.1,7.7,6.3,6.4,6,6.9,6.7,6.9,5.8,6.8,6.7,6.7,6.3,6.5,6.2,5.9])
res = fustal.one_sample_t_test(data, 6)
print("1 Sample T-Test---")
print("Fustal: ", res)
