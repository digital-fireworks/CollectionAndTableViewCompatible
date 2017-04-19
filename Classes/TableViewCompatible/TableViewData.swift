//
//  TableViewData.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

public protocol TableViewData {
    
    var sections: [TableViewSection] { get set }
    
    subscript(indexPath: IndexPath) -> TableViewCompatible { get set }
    
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func titleForHeaderInSection(section: Int) -> String?
    func titleForFooterInSection(section: Int) -> String?
    func cellForTableView(tableView: UITableView, atIndexPath: IndexPath) -> UITableViewCell
    
    // Prefetching
    func prefetchObjectsAtIndexPaths(indexPaths: [IndexPath])
    func cancelPrefetchingObjectsAtIndexPaths(indexPaths: [IndexPath])
    
}

// Default implementations
public extension TableViewData {
    
    public subscript(indexPath: IndexPath) -> TableViewCompatible {
        get {
            return sections[indexPath.section].items[indexPath.row]
        }
        set {
            var items = sections[indexPath.section].items
            items.insert(newValue, at: indexPath.row)
        }
    }
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func titleForHeaderInSection(section: Int) -> String? {
        return sections[section].headerTitle
    }
    
    public func titleForFooterInSection(section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    public func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let model = self[indexPath]
        return model.cellForTableView(tableView: tableView, atIndexPath: indexPath)
    }
    
    public func prefetchObjectsAtIndexPaths(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self[indexPath].prefetch()
        }
    }
    
    public func cancelPrefetchingObjectsAtIndexPaths(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.sections.count < indexPath.section && self.sections[indexPath.section].items.count < indexPath.row {
                self[indexPath].cancelPrefetch()
            }
        }
    }
    
}
