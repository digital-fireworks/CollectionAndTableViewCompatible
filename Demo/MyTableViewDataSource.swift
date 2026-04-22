//
//  MyTableViewData.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

@MainActor
final class MyTableViewDataSource {

    let store: GenreDemoStore
    var onChange: (() -> Void)?

    init(store: GenreDemoStore) {
        self.store = store
    }

    func makeSections() -> [TableSection] {
        let sectionModels = store.makeSectionModels(isCollectionEditing: false) { [weak self] in
            self?.notifyChange()
        }

        return sectionModels.map(makeTableSection(from:))
    }

    var areGenresSorted: Bool {
        store.areGenresSorted
    }

    @discardableResult
    func addGenre(named name: String) -> Bool {
        let didAddGenre = store.addGenre(named: name)
        if didAddGenre {
            notifyChange()
        }
        return didAddGenre
    }

    func sortGenres() {
        store.sortGenres()
        notifyChange()
    }

    private func makeTableSection(from sectionModel: GenreSectionModel) -> TableSection {
        TableSection(
            id: sectionModel.id,
            headerTitle: sectionModel.title,
            rows: sectionModel.items.map(makeGenreRow(for:))
        )
    }

    private func makeGenreRow(for itemModel: GenreSectionItemModel) -> TableRow {
        let actionTitle = itemModel.model.selected ? "Unfavorite" : "Favorite"
        let actionImage = itemModel.model.selected ? "star.slash.fill" : "star.fill"
        let actionColor = itemModel.model.selected ? UIColor.systemRed : UIColor.systemYellow

        var row = itemModel.model
            .tableViewCell(id: itemModel.id, reuseIdentifier: MainStoryboard.GenreCellIdentifier)
            .editable()
            .onDelete { [weak self] context in
                itemModel.model.onDelete?()
                guard let self else { return }
                context.apply(self.makeSections())
            }
            .trailingSwipeActions {
                TableRowAction(actionTitle, systemImage: actionImage, backgroundColor: actionColor) { [weak self] context in
                    itemModel.model.onToggleFavorite?()
                    guard let self else { return }
                    context.apply(self.makeSections())
                }
            }

        if itemModel.isMovable {
            row = row.onMove { [weak self] sourceIndexPath, destinationIndexPath in
                self?.moveGenre(from: sourceIndexPath.row, to: destinationIndexPath.row)
            }
        }

        return row
    }

    private func moveGenre(from sourceIndex: Int, to destinationIndex: Int) {
        store.moveGenre(from: sourceIndex, to: destinationIndex)
        notifyChange()
    }

    private func notifyChange() {
        onChange?()
    }
}
