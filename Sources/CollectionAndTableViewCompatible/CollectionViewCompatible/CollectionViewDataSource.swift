//
//  CollectionViewDataSource.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif

@MainActor
open class CollectionViewDataSource: NSObject, CollectionViewData, UICollectionViewDataSource {
    
    public let collectionView: UICollectionView
    open var sections: [CollectionViewSection] = []
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItemsInSection(section: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.cell(forCollectionView: collectionView, atIndexPath: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return self[indexPath].movable
    }
    
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.moveItem(atIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }

}

extension CollectionViewDataSource: UICollectionViewDataSourcePrefetching {
    
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        self.prefetchObjectsAtIndexPaths(indexPaths: indexPaths)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        self.cancelPrefetchingObjectsAtIndexPaths(indexPaths: indexPaths)
    }

}

@MainActor
open class CollectionViewItemDataSource: NSObject, CollectionViewItemData, UICollectionViewDataSource {

    public let collectionView: UICollectionView
    open var sections: [CollectionViewItemSection] = []

    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
    }

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.numberOfItemsInSection(section: section)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cell(forCollectionView: collectionView, atIndexPath: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        self[indexPath].movable
    }

    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.moveItem(atIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}

extension CollectionViewItemDataSource: UICollectionViewDataSourcePrefetching {

    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        self.prefetchObjectsAtIndexPaths(indexPaths: indexPaths)
    }

    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        self.cancelPrefetchingObjectsAtIndexPaths(indexPaths: indexPaths)
    }
}

public typealias CollectionViewCellDataSource = CollectionViewItemDataSource

public struct CollectionViewLayout {

    private let makeLayoutHandler: () -> UICollectionViewLayout

    public init(_ makeLayout: @escaping () -> UICollectionViewLayout) {
        self.makeLayoutHandler = makeLayout
    }

    public static func list(
        itemHeight: CGFloat = 56,
        spacing: CGFloat = 8,
        contentInsets: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    ) -> Self {
        Self {
            UICollectionViewCompositionalLayout { _, _ in
                makeSection(
                    columns: 1,
                    itemHeight: itemHeight,
                    spacing: spacing,
                    contentInsets: contentInsets
                )
            }
        }
    }

    public static func grid(
        columns: Int = 2,
        itemHeight: CGFloat = 96,
        spacing: CGFloat = 12,
        contentInsets: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    ) -> Self {
        Self {
            UICollectionViewCompositionalLayout { _, _ in
                makeSection(
                    columns: max(columns, 1),
                    itemHeight: itemHeight,
                    spacing: spacing,
                    contentInsets: contentInsets
                )
            }
        }
    }

    public static func adaptive(
        minimumItemWidth: CGFloat = 140,
        itemHeight: CGFloat = 96,
        spacing: CGFloat = 12,
        contentInsets: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    ) -> Self {
        Self {
            UICollectionViewCompositionalLayout { _, environment in
                let availableWidth = max(
                    environment.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing,
                    minimumItemWidth
                )
                let columns = max(Int((availableWidth + spacing) / (minimumItemWidth + spacing)), 1)
                return makeSection(
                    columns: columns,
                    itemHeight: itemHeight,
                    spacing: spacing,
                    contentInsets: contentInsets
                )
            }
        }
    }

    public static func custom(_ makeLayout: @escaping () -> UICollectionViewLayout) -> Self {
        Self(makeLayout)
    }

    func makeLayout() -> UICollectionViewLayout {
        makeLayoutHandler()
    }

    private static func makeSection(
        columns: Int,
        itemHeight: CGFloat,
        spacing: CGFloat,
        contentInsets: NSDirectionalEdgeInsets
    ) -> NSCollectionLayoutSection {
        let fraction = 1.0 / CGFloat(max(columns, 1))
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(fraction),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: spacing / 2, bottom: 0, trailing: spacing / 2)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: max(columns, 1))

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = contentInsets
        return section
    }
}

@MainActor
public final class CollectionListAdapter: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

    public let collectionView: UICollectionView
    private var sections: [CollectionViewCellSection] = []

    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
    }

    public func apply<ID: Hashable>(_ cells: [CollectionViewCell], animated: Bool = true, sectionID: ID = "main") {
        apply([CollectionViewCellSection(id: sectionID, cells: cells)], animated: animated)
    }

    public func apply(_ sections: [CollectionViewCellSection], animated: Bool = true) {
        validateIdentifiers(in: sections)

        let previousSections = self.sections
        self.sections = sections

        guard animated, previousSections.isEmpty == false, collectionView.window != nil else {
            collectionView.reloadData()
            return
        }

        guard stableSectionOrder(from: previousSections, to: sections) else {
            collectionView.reloadData()
            return
        }

        let oldSectionIDs = previousSections.map(\.id)
        let newSectionIDs = sections.map(\.id)

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

            let oldCells = previousSections[oldSectionIndex].cells
            let newCells = sections[newSectionIndex].cells
            let oldCellIDs = identifiers(for: oldCells, in: sectionID)
            let newCellIDs = identifiers(for: newCells, in: sectionID)

            deletedItems.append(contentsOf:
                oldCellIDs.enumerated().compactMap { itemIndex, identifier in
                    newCellIDs.contains(identifier) ? nil : IndexPath(item: itemIndex, section: oldSectionIndex)
                }
            )

            insertedItems.append(contentsOf:
                newCellIDs.enumerated().compactMap { itemIndex, identifier in
                    oldCellIDs.contains(identifier) ? nil : IndexPath(item: itemIndex, section: newSectionIndex)
                }
            )

            let commonCellIDs = oldCellIDs.filter(newCellIDs.contains)
            for cellID in commonCellIDs {
                guard
                    let oldCellIndex = oldCellIDs.firstIndex(of: cellID),
                    let newCellIndex = newCellIDs.firstIndex(of: cellID)
                else {
                    continue
                }

                let oldIndexPath = IndexPath(item: oldCellIndex, section: oldSectionIndex)
                let newIndexPath = IndexPath(item: newCellIndex, section: newSectionIndex)

                if oldIndexPath != newIndexPath {
                    movedItems.append((from: oldIndexPath, to: newIndexPath))
                }

                reloadedItems.append(newIndexPath)
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
            for movedItem in movedItems where movedItem.from != movedItem.to {
                collectionView.moveItem(at: movedItem.from, to: movedItem.to)
            }
        } completion: { [weak self] _ in
            guard let self else { return }

            let validReloads = reloadedItems.filter { indexPath in
                indexPath.section < self.sections.count && indexPath.item < self.sections[indexPath.section].cells.count
            }

            if validReloads.isEmpty == false {
                self.collectionView.reloadItems(at: validReloads)
            }
        }
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard sections.indices.contains(section) else {
            return 0
        }

        return sections[section].cells.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell(at: indexPath)?.cell(for: collectionView, at: indexPath) ?? UICollectionViewCell(frame: .zero)
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        cell(at: indexPath)?.movable ?? false
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            sections.indices.contains(sourceIndexPath.section),
            sections.indices.contains(destinationIndexPath.section),
            sections[sourceIndexPath.section].cells.indices.contains(sourceIndexPath.item),
            destinationIndexPath.item <= sections[destinationIndexPath.section].cells.count
        else {
            return
        }

        let movedCell = sections[sourceIndexPath.section].cells.remove(at: sourceIndexPath.item)
        sections[destinationIndexPath.section].cells.insert(movedCell, at: destinationIndexPath.item)
    }

    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cell(at: indexPath)?.prefetch()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cell(at: indexPath)?.cancelPrefetch()
        }
    }

    private func cell(at indexPath: IndexPath) -> CollectionViewCell? {
        guard
            sections.indices.contains(indexPath.section),
            sections[indexPath.section].cells.indices.contains(indexPath.item)
        else {
            return nil
        }

        return sections[indexPath.section].cells[indexPath.item]
    }

    private func identifiers(
        for cells: [CollectionViewCell],
        in sectionID: TableIdentifier
    ) -> [CollectionListItemIdentifier] {
        cells.compactMap { cell in
            guard let cellID = cell.id else {
                return nil
            }

            return CollectionListItemIdentifier(sectionID: sectionID, cellID: cellID)
        }
    }

    private func validateIdentifiers(in sections: [CollectionViewCellSection]) {
        var seenSections = Set<TableIdentifier>()

        for section in sections {
            precondition(seenSections.insert(section.id).inserted, "Duplicate CollectionViewCellSection id '\(section.id)'. Section ids must be unique.")

            var seenCells = Set<TableIdentifier>()
            for cell in section.cells {
                guard let cellID = cell.id else {
                    preconditionFailure("CollectionViewCell used with CollectionListAdapter must have a non-nil id.")
                }

                precondition(
                    seenCells.insert(cellID).inserted,
                    "Duplicate CollectionViewCell id '\(cellID)' found in section '\(section.id)'. Cell ids must be unique within their section."
                )
            }
        }
    }

    private func stableSectionOrder(from oldSections: [CollectionViewCellSection], to newSections: [CollectionViewCellSection]) -> Bool {
        let oldCommon = oldSections.map(\.id).filter { newSections.map(\.id).contains($0) }
        let newCommon = newSections.map(\.id).filter { oldSections.map(\.id).contains($0) }
        return oldCommon == newCommon
    }
}

@MainActor
public final class CollectionListViewController: UIViewController {

    public let collectionView: UICollectionView
    public let collectionListAdapter: CollectionListAdapter

    public init(layout: CollectionViewLayout = .adaptive()) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout.makeLayout())
        self.collectionListAdapter = CollectionListAdapter(collectionView: collectionView)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = .clear

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: rootView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
        ])

        view = rootView
    }

    public func setLayout(_ layout: CollectionViewLayout, animated: Bool = false) {
        collectionView.setCollectionViewLayout(layout.makeLayout(), animated: animated)
    }

    public func apply<ID: Hashable>(_ cells: [CollectionViewCell], animated: Bool = true, sectionID: ID = "main") {
        collectionListAdapter.apply(cells, animated: animated, sectionID: sectionID)
    }

    public func apply(_ sections: [CollectionViewCellSection], animated: Bool = true) {
        collectionListAdapter.apply(sections, animated: animated)
    }
}

#if canImport(SwiftUI)
@MainActor
public struct CollectionListView: UIViewControllerRepresentable {

    public let layout: CollectionViewLayout
    public let sections: [CollectionViewCellSection]
    public let animated: Bool

    public init(
        layout: CollectionViewLayout = .adaptive(),
        sections: [CollectionViewCellSection],
        animated: Bool = true
    ) {
        self.layout = layout
        self.sections = sections
        self.animated = animated
    }

    public init(
        layout: CollectionViewLayout = .adaptive(),
        animated: Bool = true,
        cells: [CollectionViewCell]
    ) {
        self.init(
            layout: layout,
            sections: [CollectionViewCellSection(id: "main", cells: cells)],
            animated: animated
        )
    }

    public init(
        layout: CollectionViewLayout = .adaptive(),
        animated: Bool = true,
        @CollectionViewCellBuilder cells: () -> [CollectionViewCell]
    ) {
        self.init(layout: layout, animated: animated, cells: cells())
    }

    public init(
        layout: CollectionViewLayout = .adaptive(),
        animated: Bool = true,
        @CollectionViewCellSectionBuilder content: () -> [CollectionViewCellSection]
    ) {
        self.init(layout: layout, sections: content(), animated: animated)
    }

    public func makeUIViewController(context: Context) -> CollectionListViewController {
        let controller = CollectionListViewController(layout: layout)
        controller.apply(sections, animated: false)
        return controller
    }

    public func updateUIViewController(_ uiViewController: CollectionListViewController, context: Context) {
        uiViewController.setLayout(layout)
        uiViewController.apply(sections, animated: animated)
    }
}
#endif

private struct CollectionListItemIdentifier: Hashable {
    let sectionID: TableIdentifier
    let cellID: TableIdentifier
}
