//
//  TableViewDataSource.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 17/11/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

open class TableViewDataSource: NSObject, TableViewData, UITableViewDataSource {

    public let tableView: UITableView
    open var sections: [TableViewSection] = []
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.prefetchDataSource = self
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRowsInSection(section: section)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cellForTableView(tableView: tableView, atIndexPath: indexPath)
    }
    
    // Optional
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections()
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titleForHeaderInSection(section: section)
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.titleForFooterInSection(section: section)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self[indexPath].editable
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self[indexPath].movable
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // If you need to update a deeper model, ie. a database or similar, or you need to support insertion, you probably want to provide your own implementation of this function.
        
        switch editingStyle {
        case .none:
            break
        case .insert:
            insertItem(atIndexPath: indexPath)
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            deleteItem(atIndexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            // Ignoring all unknown
            break
        }
    }
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // If you need to update a deeper model, ie. a database or similar, you probably want to provide your own implementation of this function.
        
        let item = self.sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
        self.sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.row)
    }
    
    open func insertItem(atIndexPath indexPath: IndexPath) {
        // Override in subclass if needed
    }
    
    open func deleteItem(atIndexPath indexPath: IndexPath) {
        self.sections[indexPath.section].items.remove(at: indexPath.row)
    }
    
}

extension TableViewDataSource: UITableViewDataSourcePrefetching {
    
    open func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        self.prefetchObjectsAtIndexPaths(indexPaths: indexPaths)
    }
    
    open func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        self.cancelPrefetchingObjectsAtIndexPaths(indexPaths: indexPaths)
    }
    
}

extension TableViewDataSource: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        // We need to check if the proposedDestinationIndexPath is out of bounds. This will happen when moving a cell past the last cell in the table view.
        
        let proposedSection = proposedDestinationIndexPath.section
        let proposedRow = proposedDestinationIndexPath.row
        
        let cellToReplace: TableViewCompatible?
        
        if proposedSection >= self.sections.count {
            // The proposed section is out of bounds. This really should not happen, but just to be safe, we perform this check.
            cellToReplace = self.sections.last?.items.last
        } else if proposedRow >= self.sections[proposedSection].items.count {
            // The proposed row is out of bounds so we use the last cell to check if movement is allowed.
            cellToReplace = self.sections[proposedSection].items.last
        } else {
            // We are all good, so we can check the cell at the proposedDestinationIndexPath.
            cellToReplace = self[proposedDestinationIndexPath]
        }
        
        // We only allow movement if the cell at the destination is movable.
        if let cellToReplace = cellToReplace, cellToReplace.movable {
            return proposedDestinationIndexPath
        } else {
            return sourceIndexPath
        }
    }
}
