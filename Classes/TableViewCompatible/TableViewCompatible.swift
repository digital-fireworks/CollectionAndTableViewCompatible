//
//  TableViewCompatible.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 21/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation
import UIKit

/**
 Let your model object conform to this protocol to make it compatible with a `UITableView`
 */
public protocol TableViewCompatible: CollectionAndTableViewCompatible {
    
    /// Call this from your `UITableViewDataSource` and return a fully configured `UITableViewCell`. If your cells conforms to the `Configurable` protocol, you can call `configureWithModel(_: T)` with `self` as parameter in your implementation.
    /// parameter tableView: a table view requesting the cell.
    /// parameter indexPath: an index path locating the row in the table view.
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell

}
