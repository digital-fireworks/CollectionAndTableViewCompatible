//
//  SimpleCellModel.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class SimpleCellModel: TableViewCompatible, CollectionViewCompatible {
    
    var reuseIdentifier: String {
        return MainStoryboard.SimpleCellIdentifier
    }
    
    var selected: Bool = false
    var string: String?
    
    init(string: String) {
        self.string = string
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SimpleTableViewCell
        cell.configure(withModel: self)
        return cell
    }
    
    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SimpleCollectionViewCell
        cell.configure(withModel: self)
        return cell
    }
}
