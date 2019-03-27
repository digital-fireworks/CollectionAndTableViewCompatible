//
//  ViewController+UITableViewDataSource.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 26/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.willDisplay()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.didEndDisplay()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.data[indexPath]
        
        switch model {
        case let model as GenreCellModel:
            handleGenreSelection(model: model, forUser: user)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return self.data.tableView(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
    }
    
    private func handleGenreSelection(model: GenreCellModel, forUser user: User) {
        if let index = user.genres.index(of: model.genre) {
            user.genres.remove(at: index)
            model.selected = false
        } else {
            user.genres.append(model.genre)
            model.selected = true
        }
    }
    
}
