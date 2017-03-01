# CollectionAndTableViewCompatible

[![Version](https://img.shields.io/cocoapods/v/CollectionAndTableViewCompatible.svg?style=flat)](http://cocoapods.org/pods/CollectionAndTableViewCompatible)
[![License](https://img.shields.io/cocoapods/l/CollectionAndTableViewCompatible.svg?style=flat)](http://cocoapods.org/pods/CollectionAndTableViewCompatible)
[![Platform](https://img.shields.io/cocoapods/p/CollectionAndTableViewCompatible.svg?style=flat)](http://cocoapods.org/pods/CollectionAndTableViewCompatible)

CollectionAndTableViewCompatible provides the boilerplate code needed for writing UITableViewDataSource and UICollectionViewDataSource implementations. In fact, when using the classes provided here, in most cases you wont have to write these implementations at all.

The main idea behind CollectionAndTableViewCompatible is to make the data model that is backing you table/collection view, more compatible with the data source protocols (UITableViewDataSource and UICollectionViewDataSource). CollectionAndTableViewCompatible provides a default and completely generic implementation of these protocols so that changes made to your model (for instance a dictionary holding you model entities) will be reflected directly in the table/collection view. This solves the problem of first updating the model and then updating the table/collection view accordingly and also increases maintainability and flexibility of the code by removing the need to configure cells based on specific index paths in `tableView:cellForRowAtIndexPath:`.

## Example project

You can find an example project demonstrating the use of CollectionAndTableViewCompatible [here](https://github.com/jayway/CollectionAndTableViewCompatibleExample).

### CocoaPods
If you are using Cocoapods you can run the example project by ading the pod (see below) and running `pod install` from the Example directory.

## Requirements

- `Swift3`
- `iOS 8+`
- `Xcode8`

## Installation

### Git submodule

Add this project as a git submodule by running the following command from the root of you existing git repo:

```shell
git submodule add https://github.com/jayway/CollectionAndTableViewCompatible.git
```

When the submodule is cloned, add the files contained in the Classes folder to your Xcode project (make sure "Copy if needed" is unchecked).

### CocoaPods

CollectionAndTableViewCompatible is also available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CollectionAndTableViewCompatible"
```

## How to use

The project is designed for use in a storyboard based application using prototype cells. For now, if you are using nibs or you are creating UI entirely in code you will have to manually register nibs or classes to you table/collection view.

The idea here, is to let your model object conform to either `TableViewCompatible` or `CollectionViewCompatible` or both and then provide cell implementations that conforms to the `Configurable` protocol for a table/collection view: 

- Make your model object conform to the `TableViewCompatible` and/or `CollectionViewCompatible` protocol. 
- Create a `UITableViewCell` and/or `UIColllectionViewCell` subclass and let them conform to the `Configurable` protocol. The `model` property type should be the type of your model object. 
- Create a subclass of `TableViewDataSource` and/or `CollectionViewDataSource` and initialize it by calling `init(tableView: UITableView)` and/or `init(collectionView: UICollectionView)`.
- Initialize the `sections` property of you data source instance by providing `TableViewSection`/`CollectionViewSection` instances containing your model objects.
- Call `reloadData()` on you table/collection view.

You are now free to add, remove and reorder sections and cells simply by modifying the `sections` property of your data source and calling `reloadData()` on the table/collection view.

To make your cells movable of editiable, simply provide a value for the `movable` and `editable` properties of your `TableViewCompatible`/`CollectionViewCompatible` model object.

Below is an example of how the `TableViewCompatible`/`CollectionViewCompatible` and `Configurable` interacts when implemented:

```swift
class MyTableCell: UITableViewCell, Configurable {
    
    var model: MyCellModel?

    func configureWithModel(_ model: MyCellModel) {
        self.model = model
        titleLabel.text = model.title
    }

}

class MyCollectionCell: UICollectionViewCell, Configurable {

    @IBOutlet weak var titleLabel: UILabel!

    var model: MyCellModel?

    func configureWithModel(_ model: MyCellModel) {
        self.model = model
        titleLabel.text = model.title
    }

}

class MyCellModel: TableViewCompatible, CollectionViewCompatible {

    // Your custom properties
    var title: String = "Some title"

    // TableViewCompatible/CollectionViewCompatible conformance
    var reuseIdentifier: String = "MyCellIdentifier"
    var selected: Bool = false
    var editable: Bool = true
    var movable: Bool = true

    // TableViewCompatible
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MyTableCell
        cell.configureWithModel(self)
        return cell
    }

    // CollectionViewCompatible
    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionCell
        cell.configureWithModel(self)
        return cell
    }

}
```

## Author

- `Fredrik Nannestad, fredrik.nannestad@jayway.com - Main author`
- `Jimmie Jensen, jimmie.jensen@jayway.com - Contributer`

## License

CollectionAndTableViewCompatible is available under the Apache License Version 2.0. See the LICENSE file for more info.
