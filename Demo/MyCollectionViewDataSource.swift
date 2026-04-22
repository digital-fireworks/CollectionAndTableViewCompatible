//
//  MyCollectionViewDataSource.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

@MainActor
final class MyCollectionViewDataSource: CollectionViewItemDataSource {

    let store: GenreDemoStore
    var isEditingGenres = false
    var onChange: (() -> Void)?
    private(set) var genreSectionIndex = 0
    private var sectionModels: [GenreSectionModel] = []

    init(store: GenreDemoStore, collectionView: UICollectionView) {
        self.store = store
        super.init(collectionView: collectionView)
    }

    var areGenresSorted: Bool {
        store.areGenresSorted
    }

    func apply(animated: Bool) {
        let previousSectionModels = sectionModels
        let nextSectionModels = store.makeSectionModels(isCollectionEditing: isEditingGenres) { [weak self] in
            self?.apply(animated: true)
        }

        sectionModels = nextSectionModels
        syncSections(from: nextSectionModels)

        guard animated, previousSectionModels.isEmpty == false, collectionView.window != nil else {
            collectionView.reloadData()
            notifyChange()
            return
        }

        animateTransition(from: previousSectionModels, to: nextSectionModels)
        notifyChange()
    }

    func sortGenres() {
        store.sortGenres()
        apply(animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            sourceIndexPath.section == genreSectionIndex,
            destinationIndexPath.section == genreSectionIndex
        else {
            return
        }

        store.moveGenre(from: sourceIndexPath.item, to: destinationIndexPath.item)
        sectionModels = store.makeSectionModels(isCollectionEditing: isEditingGenres) { [weak self] in
            self?.apply(animated: true)
        }
        syncSections(from: sectionModels)
        notifyChange()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CollectionSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! CollectionSectionHeaderView
        view.configure(title: title(forSection: indexPath.section))
        return view
    }

    func title(forSection section: Int) -> String {
        guard sectionModels.indices.contains(section) else {
            return ""
        }

        return sectionModels[section].title
    }

    private func syncSections(from sectionModels: [GenreSectionModel]) {
        genreSectionIndex = sectionModels.firstIndex { $0.id == .genres } ?? 0
        sections = sectionModels.enumerated().map { index, sectionModel in
            CollectionViewItemSection(
                sortOrder: index,
                items: sectionModel.items.map { itemModel in
                    itemModel.model.collectionViewCell(
                        id: itemModel.id,
                        reuseIdentifier: MainStoryboard.GenreCellIdentifier,
                        movable: itemModel.isMovable
                    )
                }
            )
        }
    }

    private func animateTransition(from oldSections: [GenreSectionModel], to newSections: [GenreSectionModel]) {
        let oldSectionIDs = oldSections.map(\.id)
        let newSectionIDs = newSections.map(\.id)

        let deletedSections = IndexSet(
            oldSectionIDs.enumerated().compactMap { index, identifier in
                newSectionIDs.contains(identifier) ? nil : index
            }
        )
        let insertedSections = IndexSet(
            newSectionIDs.enumerated().compactMap { index, identifier in
                oldSectionIDs.contains(identifier) ? nil : index
            }
        )

        var deletedItems = [IndexPath]()
        var insertedItems = [IndexPath]()
        var movedItems = [(from: IndexPath, to: IndexPath)]()
        var reloadedItems = [IndexPath]()

        let commonSectionIDs = oldSectionIDs.filter(newSectionIDs.contains)
        for sectionID in commonSectionIDs {
            guard
                let oldSectionIndex = oldSectionIDs.firstIndex(of: sectionID),
                let newSectionIndex = newSectionIDs.firstIndex(of: sectionID)
            else {
                continue
            }

            let oldItems = oldSections[oldSectionIndex].items
            let newItems = newSections[newSectionIndex].items
            let oldItemIDs = oldItems.map(\.id)
            let newItemIDs = newItems.map(\.id)

            deletedItems.append(contentsOf:
                oldItemIDs.enumerated().compactMap { itemIndex, identifier in
                    newItemIDs.contains(identifier) ? nil : IndexPath(item: itemIndex, section: oldSectionIndex)
                }
            )

            insertedItems.append(contentsOf:
                newItemIDs.enumerated().compactMap { itemIndex, identifier in
                    oldItemIDs.contains(identifier) ? nil : IndexPath(item: itemIndex, section: newSectionIndex)
                }
            )

            let commonItemIDs = oldItemIDs.filter(newItemIDs.contains)
            for itemID in commonItemIDs {
                guard
                    let oldItemIndex = oldItemIDs.firstIndex(of: itemID),
                    let newItemIndex = newItemIDs.firstIndex(of: itemID)
                else {
                    continue
                }

                let oldItem = oldItems[oldItemIndex]
                let newItem = newItems[newItemIndex]

                if oldSectionIndex == newSectionIndex, oldItemIndex != newItemIndex {
                    movedItems.append((
                        from: IndexPath(item: oldItemIndex, section: oldSectionIndex),
                        to: IndexPath(item: newItemIndex, section: newSectionIndex)
                    ))
                }

                if oldItem.contentState != newItem.contentState {
                    reloadedItems.append(IndexPath(item: newItemIndex, section: newSectionIndex))
                }
            }
        }

        collectionView.performBatchUpdates {
            if deletedSections.isEmpty == false {
                collectionView.deleteSections(deletedSections)
            }
            if insertedSections.isEmpty == false {
                collectionView.insertSections(insertedSections)
            }
            if deletedItems.isEmpty == false {
                collectionView.deleteItems(at: deletedItems)
            }
            if insertedItems.isEmpty == false {
                collectionView.insertItems(at: insertedItems)
            }
            for move in movedItems {
                collectionView.moveItem(at: move.from, to: move.to)
            }
        } completion: { [weak self] _ in
            guard let self else { return }

            let validReloads = reloadedItems.filter { indexPath in
                indexPath.section < self.sectionModels.count &&
                indexPath.item < self.sectionModels[indexPath.section].items.count
            }

            if validReloads.isEmpty == false {
                self.collectionView.reloadItems(at: validReloads)
            }
        }
    }

    private func notifyChange() {
        onChange?()
    }
}
