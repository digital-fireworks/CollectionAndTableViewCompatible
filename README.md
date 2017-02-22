# CollectionAndTableViewCompatible

[![Version](https://img.shields.io/cocoapods/v/CollectionAndTableViewCompatible.svg?style=flat)](http://cocoapods.org/pods/CollectionAndTableViewCompatible)
[![License](https://img.shields.io/cocoapods/l/CollectionAndTableViewCompatible.svg?style=flat)](http://cocoapods.org/pods/CollectionAndTableViewCompatible)
[![Platform](https://img.shields.io/cocoapods/p/CollectionAndTableViewCompatible.svg?style=flat)](http://cocoapods.org/pods/CollectionAndTableViewCompatible)

A set of Swift protocols and Xcode snippets that will make it easy to do clean UICollectionView and UITableView code.

## Example project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- `Swift3`
- `iOS 8+`
- `Xcode8`

## Installation

CollectionAndTableViewCompatible is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CollectionAndTableViewCompatible"
```

## How to use
The project consists of three protocols:

- `TableViewCompatible`
- `Configurable`
- `TableViewSection`

Create a view model that conforms to the `TableViewCompatible` protocol. The view model could either be a separate class or an extension to your existing model obejct. Your choice.

The create a `UITableViewCell` subclass that conforms to the `Configurable` protocol. Make the function `configureWithModel` take an instance of your view model as parameter.

Finally create a class or struct that conforms to the `TableViewSection` protocol and let your `UITableViewDataSource` data model be an array of `TableViewSection`.

For a more detailed explaination see this [blog post](https://blog.jayway.com/2016/11/15/clean-table-view-code-using-swift-protocols/)


## Author

- `Fredrik Nannestad, fredrik.nannestad@jayway.com - Main author`
- `Jimmie Jensen, jimmie.jensen@jayway.com - Contributer`

## License

CollectionAndTableViewCompatible is available under the Apache License Version 2.0. See the LICENSE file for more info.
