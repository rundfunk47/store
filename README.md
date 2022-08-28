# Store

[![Language](https://img.shields.io/static/v1.svg?label=language&message=Swift%205&color=FA7343&logo=swift&style=flat-square)](https://swift.org)
[![Platform](https://img.shields.io/static/v1.svg?label=platforms&message=iOS%20|%20tvOS%20|%20watchOS%20|%20macOS&logo=apple&style=flat-square)](https://apple.com)
[![License](https://img.shields.io/cocoapods/l/Crossroad.svg?style=flat-square)](https://github.com/rundfunk47/store/blob/main/LICENSE)

Simple, powerful and elegant implementation of the repository pattern, using generics. 

# Why? 🤔

There are a couple of ways to implement the Repository-pattern in Swift. Creating custom classes for each one of your stores will lead to a lot of boiler-plate. Also, you'd probably need to implement support for Combine, `async`-functions to fetch the data etc.

# What? 🤷🏽‍♂️

In order to remedy this, `Store` provides two generic protocols `ReadStore` and `Store` that can be used. It also comes with some implementations out-of-the-box: 

* `AsyncStore` for feching data asynchronously.
* `MemoryStore` for when you already have the data on hand.

Stores have a state (loading, error or loaded) and also have a `fetch()`-function to do the initial fetching. Stores can be chained using the `chainWith()`-function. This means, you can use the output from the first fetch as input for a second fetch. Perfect when you for instance get an ID from a network call and need to do another call to fetch the entity. You can also do parallel fetching (using the `parallel()`-function). If any of these calls fail, the store state will be errored. The stores can be mapped, unwrapped etc.


