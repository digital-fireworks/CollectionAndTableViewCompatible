//
//  ImageCell.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class UserCellModel: TableViewCompatible, CollectionViewCompatible {
    
    var reuseIdentifier: String {
        return MainStoryboard.UserCellIdentifier
    }

    let imageName: String
    let userName: String
    
    var selected: Bool = false
    
    init(userName: String, imageName: String) {
        self.userName = userName
        self.imageName = imageName
    }
    
    convenience init(user: User) {
        self.init(userName: user.name, imageName: user.imageName)
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserTableViewCell
        cell.configure(withModel: self)
        return cell
    }
    
    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCollectionViewCell
        cell.configure(withModel: self)
        return cell
    }
    
    func prefetch() {
        // Perform prefetching, for instance fetching data from the internet
    }
    
    func cancelPrefetch() {
        // Cancel any prefetching started in prefetch()
    }
    
}
