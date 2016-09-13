# Some functional programming helpers to make things more readable...
from functools import reduce


def compose(*functions):
    """
    composes several functions together
    compose(f, g, h)(x) == f(g(h(x)))
    """
    return reduce(lambda f, g: lambda x: f(g(x)), functions, lambda x: x)


def identity(x):
    return x


def branch(condition, truthy, falsy):
    """
    conditionally applies one of two functions:
    branch(True, lambda x: x+1, lambda: x*2)(10) == 11
    branch(False, lambda x: x+1, lambda: x*2)(10) == 20
    """
    def func(*args, **kwargs):
        if condition:
            return truthy(*args, **kwargs)
        return falsy(*args, **kwargs)
    return func
