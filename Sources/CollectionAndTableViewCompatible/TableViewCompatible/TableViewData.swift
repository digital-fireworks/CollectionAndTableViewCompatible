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
    
    subscript(indexPath: IndexPath) -> TableViewCompatible {
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
    
    func numberOfRowsInSection(section: Int) -> Int {
        return sections[section].items.count
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return sections[section].headerTitle
    }
    
    func titleForFooterInSection(section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let model = self[indexPath]
        return model.cellForTableView(tableView: tableView, atIndexPath: indexPath)
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
