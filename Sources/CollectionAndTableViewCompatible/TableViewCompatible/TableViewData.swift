//
//  TableViewData.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

@MainActor
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
            sections[indexPath.section].items[indexPath.row] = newValue
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

@MainActor
public protocol TableViewRowData {

    var sections: [TableViewRowSection] { get set }

    subscript(indexPath: IndexPath) -> TableViewRow { get set }

    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func titleForHeaderInSection(section: Int) -> String?
    func titleForFooterInSection(section: Int) -> String?
    func cellForTableView(tableView: UITableView, atIndexPath: IndexPath) -> UITableViewCell

    func prefetchObjectsAtIndexPaths(indexPaths: [IndexPath])
    func cancelPrefetchingObjectsAtIndexPaths(indexPaths: [IndexPath])
}

public extension TableViewRowData {

    subscript(indexPath: IndexPath) -> TableViewRow {
        get {
            sections[indexPath.section].items[indexPath.row]
        }
        set {
            sections[indexPath.section].items[indexPath.row] = newValue
        }
    }

    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfRowsInSection(section: Int) -> Int {
        sections[section].items.count
    }

    func titleForHeaderInSection(section: Int) -> String? {
        sections[section].headerTitle
    }

    func titleForFooterInSection(section: Int) -> String? {
        sections[section].footerTitle
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        self[indexPath].cell(for: tableView, at: indexPath)
    }

    func prefetchObjectsAtIndexPaths(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self[indexPath].prefetch()
        }
    }

    func cancelPrefetchingObjectsAtIndexPaths(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.section < sections.count && indexPath.row < sections[indexPath.section].items.count {
                self[indexPath].cancelPrefetch()
            }
        }
    }
}
