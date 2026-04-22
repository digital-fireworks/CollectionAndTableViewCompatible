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
@MainActor
public protocol CollectionViewCompatible: CollectionAndTableViewCompatible {
    
    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell
    
}

@MainActor
public protocol CollectionViewCellModel {
    associatedtype CollectionCell: UICollectionViewCell & Configurable where CollectionCell.T == Self
}

public typealias CollectionViewItemModel = CollectionViewCellModel

public extension CollectionViewCellModel {

    func collectionViewCell<ID: Hashable>(id: ID, movable: Bool = false) -> CollectionViewCell {
        CollectionViewCell(id: id, cellType: CollectionCell.self, model: self, movable: movable)
    }

    func collectionViewCell<ID: Hashable>(id: ID, reuseIdentifier: String, movable: Bool = false) -> CollectionViewCell {
        CollectionViewCell(
            id: id,
            cellType: CollectionCell.self,
            model: self,
            reuseIdentifier: reuseIdentifier,
            movable: movable
        )
    }

    @available(*, deprecated, renamed: "collectionViewCell(id:movable:)")
    func collectionViewItem(movable: Bool = false) -> CollectionViewCell {
        CollectionViewCell(cellType: CollectionCell.self, model: self, movable: movable)
    }

    @available(*, deprecated, renamed: "collectionViewCell(id:reuseIdentifier:movable:)")
    func collectionViewItem(reuseIdentifier: String, movable: Bool = false) -> CollectionViewCell {
        CollectionViewCell(
            cellType: CollectionCell.self,
            model: self,
            reuseIdentifier: reuseIdentifier,
            movable: movable
        )
    }
}

public extension CollectionViewCellModel where Self: Identifiable {

    func collectionViewCell(movable: Bool = false) -> CollectionViewCell {
        collectionViewCell(id: id, movable: movable)
    }

    func collectionViewCell(reuseIdentifier: String, movable: Bool = false) -> CollectionViewCell {
        collectionViewCell(id: id, reuseIdentifier: reuseIdentifier, movable: movable)
    }

    @available(*, deprecated, renamed: "collectionViewCell(movable:)")
    func collectionViewItem(movable: Bool = false) -> CollectionViewCell {
        collectionViewCell(id: id, movable: movable)
    }

    @available(*, deprecated, renamed: "collectionViewCell(reuseIdentifier:movable:)")
    func collectionViewItem(reuseIdentifier: String, movable: Bool = false) -> CollectionViewCell {
        collectionViewCell(id: id, reuseIdentifier: reuseIdentifier, movable: movable)
    }
}

@MainActor
public struct CollectionViewCell {

    public let id: TableIdentifier?
    public let representedValue: Any
    public let movable: Bool

    private let cellProvider: (UICollectionView, IndexPath) -> UICollectionViewCell
    private let prefetchHandler: () -> Void
    private let cancelPrefetchHandler: () -> Void

    init(
        id: TableIdentifier?,
        representedValue: Any,
        movable: Bool = false,
        cellProvider: @escaping (UICollectionView, IndexPath) -> UICollectionViewCell,
        prefetchHandler: @escaping () -> Void = {},
        cancelPrefetchHandler: @escaping () -> Void = {}
    ) {
        self.id = id
        self.representedValue = representedValue
        self.movable = movable
        self.prefetchHandler = prefetchHandler
        self.cancelPrefetchHandler = cancelPrefetchHandler
        self.cellProvider = cellProvider
    }

    public init<ID: Hashable, Cell: UICollectionViewCell, Model>(
        id: ID,
        cellType: Cell.Type,
        model: Model,
        reuseIdentifier: String,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {},
        configure: @escaping (Cell, Model) -> Void
    ) {
        self.init(
            id: TableIdentifier(id),
            representedValue: model,
            movable: movable,
            cellProvider: { collectionView, indexPath in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Cell
                configure(cell, model)
                return cell
            },
            prefetchHandler: prefetch,
            cancelPrefetchHandler: cancelPrefetch
        )
    }

    public init<Cell: UICollectionViewCell, Model>(
        cellType: Cell.Type,
        model: Model,
        reuseIdentifier: String,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {},
        configure: @escaping (Cell, Model) -> Void
    ) {
        self.init(
            id: nil,
            representedValue: model,
            movable: movable,
            cellProvider: { collectionView, indexPath in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Cell
                configure(cell, model)
                return cell
            },
            prefetchHandler: prefetch,
            cancelPrefetchHandler: cancelPrefetch
        )
    }

    public init<ID: Hashable, Cell: UICollectionViewCell & Configurable>(
        id: ID,
        cellType: Cell.Type,
        model: Cell.T,
        reuseIdentifier: String,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {}
    ) {
        self.init(
            id: id,
            cellType: cellType,
            model: model,
            reuseIdentifier: reuseIdentifier,
            movable: movable,
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch
        ) { cell, model in
            cell.model = model
            cell.configure(withModel: model)
        }
    }

    public init<Cell: UICollectionViewCell & Configurable>(
        cellType: Cell.Type,
        model: Cell.T,
        reuseIdentifier: String,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {}
    ) {
        self.init(
            cellType: cellType,
            model: model,
            reuseIdentifier: reuseIdentifier,
            movable: movable,
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch
        ) { cell, model in
            cell.model = model
            cell.configure(withModel: model)
        }
    }

    public init<ID: Hashable, Cell: UICollectionViewCell, Model>(
        id: ID,
        cellType: Cell.Type,
        model: Model,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {},
        configure: @escaping (Cell, Model) -> Void
    ) {
        let registration = UICollectionView.CellRegistration<Cell, Model> { cell, _, model in
            configure(cell, model)
        }

        self.init(
            id: TableIdentifier(id),
            representedValue: model,
            movable: movable,
            cellProvider: { collectionView, indexPath in
                collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: model)
            },
            prefetchHandler: prefetch,
            cancelPrefetchHandler: cancelPrefetch
        )
    }

    public init<Cell: UICollectionViewCell, Model>(
        cellType: Cell.Type,
        model: Model,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {},
        configure: @escaping (Cell, Model) -> Void
    ) {
        let registration = UICollectionView.CellRegistration<Cell, Model> { cell, _, model in
            configure(cell, model)
        }

        self.init(
            id: nil,
            representedValue: model,
            movable: movable,
            cellProvider: { collectionView, indexPath in
                collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: model)
            },
            prefetchHandler: prefetch,
            cancelPrefetchHandler: cancelPrefetch
        )
    }

    public init<ID: Hashable, Cell: UICollectionViewCell & Configurable>(
        id: ID,
        cellType: Cell.Type,
        model: Cell.T,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {}
    ) {
        self.init(
            id: id,
            cellType: cellType,
            model: model,
            movable: movable,
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch
        ) { cell, model in
            cell.model = model
            cell.configure(withModel: model)
        }
    }

    public init<Cell: UICollectionViewCell & Configurable>(
        cellType: Cell.Type,
        model: Cell.T,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {}
    ) {
        self.init(
            cellType: cellType,
            model: model,
            movable: movable,
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch
        ) { cell, model in
            cell.model = model
            cell.configure(withModel: model)
        }
    }

    public func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        cellProvider(collectionView, indexPath)
    }

    public func prefetch() {
        prefetchHandler()
    }

    public func cancelPrefetch() {
        cancelPrefetchHandler()
    }

    public func model<Model>(as type: Model.Type = Model.self) -> Model? {
        representedValue as? Model
    }
}

public typealias CollectionViewItem = CollectionViewCell

public extension CollectionViewCompatible {

    func collectionViewCell<ID: Hashable>(id: ID) -> CollectionViewCell {
        CollectionViewCell(
            id: TableIdentifier(id),
            representedValue: self,
            movable: movable,
            cellProvider: { collectionView, indexPath in
                self.cellForCollectionView(collectionView: collectionView, atIndexPath: indexPath)
            },
            prefetchHandler: { self.prefetch() },
            cancelPrefetchHandler: { self.cancelPrefetch() }
        )
    }
}
