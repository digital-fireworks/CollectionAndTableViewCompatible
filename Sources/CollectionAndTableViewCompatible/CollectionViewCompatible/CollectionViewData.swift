//
//  CollectionViewData.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit

public protocol CollectionViewData {
    
    var sections: [CollectionViewSection] { get set }
    
    subscript(indexPath: IndexPath) -> CollectionViewCompatible { get set }
    
    func numberOfSections() -> Int
    func numberOfItemsInSection(section: Int) -> Int
    
    func cell(forCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell
    
    func canMoveItem(atIndexPath indexPath: IndexPath) -> Bool
    func moveItem(atIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath)
    
    func prefetchObjectsAtIndexPaths(indexPaths: [IndexPath])
    func cancelPrefetchingObjectsAtIndexPaths(indexPaths: [IndexPath])
    
}

public extension CollectionViewData {
    
    subscript(indexPath: IndexPath) -> CollectionViewCompatible {
        get {
            return sections[indexPath.section].items[indexPath.row]
        }
        set {
            var items = sections[indexPath.section].items
            items.insert(newValue, at: indexPath.row)
        }
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return sections[section].items.count
    }
    
    func cell(forCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let model = self[indexPath]
        return model.cellForCollectionView(collectionView: collectionView, atIndexPath: indexPath)
    }
    
    func canMoveItem(atIndexPath indexPath: IndexPath) -> Bool {
        return self[indexPath].movable
    }
    
    func moveItem(atIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        
        // If you need to update a deeper model, ie. a database or similar, you probably want to provide your own implementation of this function.
        
        let item = self.sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
        self.sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.row)
    }
    
    func prefetchObjectsAtIndexPaths(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self[indexPath].prefetch()
        }
    }
    
    func cancelPrefetchingObjectsAtIndexPaths(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.section < self.sections.count && indexPath.row < self.sections[indexPath.section].items.count {
                self[indexPath].cancelPrefetch()
            }
        }
    }
    
}
