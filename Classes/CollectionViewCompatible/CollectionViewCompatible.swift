//
//  CollectionViewCompatible.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

/**
 Let your (view) model object conform to this protocol to make it compatible with a `UICollectionViewView`
 */
public protocol CollectionViewCompatible: CollectionAndTableViewCompatible {
    
    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell
    
}
