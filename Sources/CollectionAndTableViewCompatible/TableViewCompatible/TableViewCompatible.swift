//
//  TableViewCompatible.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 21/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation
import UIKit

public struct TableIdentifier: Hashable, CustomStringConvertible, @unchecked Sendable {

    public let rawValue: AnyHashable

    public init<ID: Hashable>(_ rawValue: ID) {
        self.rawValue = AnyHashable(rawValue)
    }

    public var description: String {
        String(describing: rawValue)
    }
}

/**
 Let your model object conform to this protocol to make it compatible with a `UITableView`
 */
@MainActor
public protocol TableViewCompatible: CollectionAndTableViewCompatible {

    /// Call this from your `UITableViewDataSource` and return a fully configured `UITableViewCell`. If your cells conforms to the `Configurable` protocol, you can call `configureWithModel(_: T)` with `self` as parameter in your implementation.
    /// parameter tableView: a table view requesting the cell.
    /// parameter indexPath: an index path locating the row in the table view.
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell

}

@MainActor
public struct TableRowContext {

    public let tableView: UITableView
    public let indexPath: IndexPath
    public let section: TableSection
    public let row: TableRow

    private let refreshHandler: (Bool) -> Void
    private let applyHandler: ([TableSection], Bool) -> Void

    init(
        tableView: UITableView,
        indexPath: IndexPath,
        section: TableSection,
        row: TableRow,
        refreshHandler: @escaping (Bool) -> Void,
        applyHandler: @escaping ([TableSection], Bool) -> Void
    ) {
        self.tableView = tableView
        self.indexPath = indexPath
        self.section = section
        self.row = row
        self.refreshHandler = refreshHandler
        self.applyHandler = applyHandler
    }

    public func refresh(animated: Bool = true) {
        refreshHandler(animated)
    }

    public func apply(_ sections: [TableSection], animated: Bool = true) {
        applyHandler(sections, animated)
    }
}

public typealias TableRowSelectionContext = TableRowContext
public typealias TableRowActionContext = TableRowContext
public typealias TableRowMoveHandler = (_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void

@MainActor
public enum TableRowSwipeEdge {
    case leading
    case trailing
}

@resultBuilder
public enum TableRowActionBuilder {

    public static func buildBlock(_ components: [TableRowAction]...) -> [TableRowAction] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: TableRowAction) -> [TableRowAction] {
        [expression]
    }

    public static func buildExpression(_ expression: [TableRowAction]) -> [TableRowAction] {
        expression
    }

    public static func buildOptional(_ component: [TableRowAction]?) -> [TableRowAction] {
        component ?? []
    }

    public static func buildEither(first component: [TableRowAction]) -> [TableRowAction] {
        component
    }

    public static func buildEither(second component: [TableRowAction]) -> [TableRowAction] {
        component
    }

    public static func buildArray(_ components: [[TableRowAction]]) -> [TableRowAction] {
        components.flatMap { $0 }
    }
}

@MainActor
public struct TableRowAction {

    public enum Role {
        case normal
        case destructive
    }

    public var title: String
    public var role: Role
    public var systemImage: String?
    public var backgroundColor: UIColor?

    private let handler: (TableRowContext) -> Void

    public init(
        _ title: String,
        role: Role = .normal,
        systemImage: String? = nil,
        backgroundColor: UIColor? = nil,
        handler: @escaping (TableRowContext) -> Void
    ) {
        self.title = title
        self.role = role
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.handler = handler
    }

    public func backgroundColor(_ color: UIColor) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    func perform(with context: TableRowContext) {
        handler(context)
    }
}

@MainActor
public protocol TableViewCellModel {
    associatedtype Cell: UITableViewCell & Configurable where Cell.T == Self
}

public typealias TableRowModel = TableViewCellModel

public extension TableViewCellModel {

    func tableViewCell<ID: Hashable>(id: ID) -> TableViewCell {
        TableViewCell(id: id, model: self, cell: Cell.self)
    }

    func tableViewCell<ID: Hashable>(id: ID, reuseIdentifier: String) -> TableViewCell {
        TableViewCell(id: id, model: self, cell: Cell.self, reuseIdentifier: reuseIdentifier)
    }

    @available(*, deprecated, renamed: "tableViewCell(id:)")
    func tableRow<ID: Hashable>(id: ID) -> TableViewCell {
        tableViewCell(id: id)
    }

    @available(*, deprecated, renamed: "tableViewCell(id:reuseIdentifier:)")
    func tableRow<ID: Hashable>(id: ID, reuseIdentifier: String) -> TableViewCell {
        tableViewCell(id: id, reuseIdentifier: reuseIdentifier)
    }
}

public extension TableViewCellModel where Self: Identifiable {

    func tableViewCell() -> TableViewCell {
        tableViewCell(id: id)
    }

    func tableViewCell(reuseIdentifier: String) -> TableViewCell {
        tableViewCell(id: id, reuseIdentifier: reuseIdentifier)
    }

    @available(*, deprecated, renamed: "tableViewCell()")
    func tableRow() -> TableViewCell {
        tableViewCell(id: id)
    }

    @available(*, deprecated, renamed: "tableViewCell(reuseIdentifier:)")
    func tableRow(reuseIdentifier: String) -> TableViewCell {
        tableViewCell(id: id, reuseIdentifier: reuseIdentifier)
    }
}

@MainActor
struct TableRowSwipeActions {

    var actions: [TableRowAction] = []
    var allowsFullSwipe = true

    var isEmpty: Bool {
        actions.isEmpty
    }
}

@MainActor
public struct TableViewCell {

    public let id: TableIdentifier
    public let representedValue: Any
    public private(set) var accessoryType: UITableViewCell.AccessoryType = .none
    public private(set) var isEditable = false
    public private(set) var isMovable = false

    private let cellProvider: (UITableView, IndexPath) -> UITableViewCell
    private let prefetchHandler: () -> Void
    private let cancelPrefetchHandler: () -> Void

    private var selectionHandler: ((TableRowContext) -> Void)?
    private var deleteHandler: ((TableRowContext) -> Void)?
    private var moveHandler: TableRowMoveHandler?
    private var leadingSwipeActions = TableRowSwipeActions()
    private var trailingSwipeActions = TableRowSwipeActions()

    init(
        id: TableIdentifier,
        representedValue: Any,
        isEditable: Bool = false,
        isMovable: Bool = false,
        cellProvider: @escaping (UITableView, IndexPath) -> UITableViewCell,
        prefetchHandler: @escaping () -> Void = {},
        cancelPrefetchHandler: @escaping () -> Void = {}
    ) {
        self.id = id
        self.representedValue = representedValue
        self.isEditable = isEditable
        self.isMovable = isMovable
        self.cellProvider = cellProvider
        self.prefetchHandler = prefetchHandler
        self.cancelPrefetchHandler = cancelPrefetchHandler
    }

    public init<Cell: UITableViewCell, Model, ID: Hashable>(
        id: ID,
        model: Model,
        cell: Cell.Type,
        reuseIdentifier: String? = nil,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {},
        configure: @escaping (Cell, Model) -> Void
    ) {
        let itemID = TableIdentifier(id)

        if let reuseIdentifier {
            self.init(
                id: itemID,
                representedValue: model,
                cellProvider: { tableView, indexPath in
                    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
                    configure(cell, model)
                    return cell
                },
                prefetchHandler: prefetch,
                cancelPrefetchHandler: cancelPrefetch
            )
        } else {
            let registrar = TableViewCellRegistrar<Cell>(reuseIdentifier: String(describing: cell))

            self.init(
                id: itemID,
                representedValue: model,
                cellProvider: { tableView, indexPath in
                    registrar.registerIfNeeded(on: tableView)
                    let cell = tableView.dequeueReusableCell(withIdentifier: registrar.reuseIdentifier, for: indexPath) as! Cell
                    configure(cell, model)
                    return cell
                },
                prefetchHandler: prefetch,
                cancelPrefetchHandler: cancelPrefetch
            )
        }
    }

    public init<Cell: UITableViewCell & Configurable, ID: Hashable>(
        id: ID,
        model: Cell.T,
        cell: Cell.Type,
        reuseIdentifier: String? = nil,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {}
    ) {
        self.init(
            id: id,
            model: model,
            cell: cell,
            reuseIdentifier: reuseIdentifier,
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch
        ) { cell, model in
            cell.model = model
            cell.configure(withModel: model)
        }
    }

    public func accessory(_ type: UITableViewCell.AccessoryType) -> Self {
        var copy = self
        copy.accessoryType = type
        return copy
    }

    public func editable(_ editable: Bool = true) -> Self {
        var copy = self
        copy.isEditable = editable
        return copy
    }

    public func movable(_ movable: Bool = true) -> Self {
        var copy = self
        copy.isMovable = movable
        return copy
    }

    public func onSelect(_ handler: @escaping (TableRowSelectionContext) -> Void) -> Self {
        var copy = self
        copy.selectionHandler = handler
        return copy
    }

    public func onDelete(_ handler: @escaping (TableRowActionContext) -> Void) -> Self {
        var copy = self
        copy.isEditable = true
        copy.deleteHandler = handler
        return copy
    }

    public func onMove(_ handler: @escaping TableRowMoveHandler) -> Self {
        var copy = self
        copy.isMovable = true
        copy.moveHandler = handler
        return copy
    }

    public func swipeActions(
        edge: TableRowSwipeEdge = .trailing,
        allowsFullSwipe: Bool = true,
        @TableRowActionBuilder _ actions: () -> [TableRowAction]
    ) -> Self {
        var copy = self
        let configuration = TableRowSwipeActions(actions: actions(), allowsFullSwipe: allowsFullSwipe)

        switch edge {
        case .leading:
            copy.leadingSwipeActions = configuration
        case .trailing:
            copy.trailingSwipeActions = configuration
        }

        return copy
    }

    public func leadingSwipeActions(
        allowsFullSwipe: Bool = true,
        @TableRowActionBuilder _ actions: () -> [TableRowAction]
    ) -> Self {
        swipeActions(edge: .leading, allowsFullSwipe: allowsFullSwipe, actions)
    }

    public func trailingSwipeActions(
        allowsFullSwipe: Bool = true,
        @TableRowActionBuilder _ actions: () -> [TableRowAction]
    ) -> Self {
        swipeActions(edge: .trailing, allowsFullSwipe: allowsFullSwipe, actions)
    }

    public func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = cellProvider(tableView, indexPath)
        cell.accessoryType = accessoryType
        return cell
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

    func performSelection(with context: TableRowContext) {
        selectionHandler?(context)
    }

    func performDelete(with context: TableRowContext) {
        deleteHandler?(context)
    }

    func performMove(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveHandler?(sourceIndexPath, destinationIndexPath)
    }

    func swipeActions(for edge: TableRowSwipeEdge) -> TableRowSwipeActions {
        switch edge {
        case .leading:
            leadingSwipeActions
        case .trailing:
            trailingSwipeActions
        }
    }

    var hasDeleteHandler: Bool {
        deleteHandler != nil
    }
}

public extension TableViewCompatible {

    func tableViewCell<ID: Hashable>(id: ID) -> TableViewCell {
        TableViewCell(
            id: TableIdentifier(id),
            representedValue: self,
            isEditable: editable,
            isMovable: movable,
            cellProvider: { tableView, indexPath in
                self.cellForTableView(tableView: tableView, atIndexPath: indexPath)
            },
            prefetchHandler: { self.prefetch() },
            cancelPrefetchHandler: { self.cancelPrefetch() }
        )
    }

    @available(*, deprecated, renamed: "tableViewCell(id:)")
    func tableRow<ID: Hashable>(id: ID) -> TableViewCell {
        tableViewCell(id: id)
    }
}

public extension TableViewRow {

    func tableViewCell<ID: Hashable>(id: ID) -> TableViewCell {
        TableViewCell(
            id: TableIdentifier(id),
            representedValue: representedValue,
            isEditable: editable,
            isMovable: movable,
            cellProvider: { tableView, indexPath in
                self.cell(for: tableView, at: indexPath)
            },
            prefetchHandler: { self.prefetch() },
            cancelPrefetchHandler: { self.cancelPrefetch() }
        )
    }

    @available(*, deprecated, renamed: "tableViewCell(id:)")
    func tableRow<ID: Hashable>(id: ID) -> TableViewCell {
        tableViewCell(id: id)
    }
}

public typealias TableRow = TableViewCell

@MainActor
public struct TableViewRow {

    public let representedValue: Any
    public let editable: Bool
    public let movable: Bool

    private let cellProvider: (UITableView, IndexPath) -> UITableViewCell
    private let prefetchHandler: () -> Void
    private let cancelPrefetchHandler: () -> Void

    public init<Cell: UITableViewCell, Model>(
        cellType: Cell.Type,
        model: Model,
        reuseIdentifier: String,
        editable: Bool = false,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {},
        configure: @escaping (Cell, Model) -> Void
    ) {
        self.representedValue = model
        self.editable = editable
        self.movable = movable
        self.prefetchHandler = prefetch
        self.cancelPrefetchHandler = cancelPrefetch
        self.cellProvider = { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
            configure(cell, model)
            return cell
        }
    }

    public init<Cell: UITableViewCell & Configurable>(
        cellType: Cell.Type,
        model: Cell.T,
        reuseIdentifier: String,
        editable: Bool = false,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {}
    ) {
        self.init(
            cellType: cellType,
            model: model,
            reuseIdentifier: reuseIdentifier,
            editable: editable,
            movable: movable,
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch
        ) { cell, model in
            cell.model = model
            cell.configure(withModel: model)
        }
    }

    public init<Cell: UITableViewCell, Model>(
        cellType: Cell.Type,
        model: Model,
        editable: Bool = false,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {},
        configure: @escaping (Cell, Model) -> Void
    ) {
        let registrar = TableViewCellRegistrar<Cell>(reuseIdentifier: String(describing: cellType))

        self.representedValue = model
        self.editable = editable
        self.movable = movable
        self.prefetchHandler = prefetch
        self.cancelPrefetchHandler = cancelPrefetch
        self.cellProvider = { tableView, indexPath in
            registrar.registerIfNeeded(on: tableView)
            let cell = tableView.dequeueReusableCell(withIdentifier: registrar.reuseIdentifier, for: indexPath) as! Cell
            configure(cell, model)
            return cell
        }
    }

    public init<Cell: UITableViewCell & Configurable>(
        cellType: Cell.Type,
        model: Cell.T,
        editable: Bool = false,
        movable: Bool = false,
        prefetch: @escaping () -> Void = {},
        cancelPrefetch: @escaping () -> Void = {}
    ) {
        self.init(
            cellType: cellType,
            model: model,
            editable: editable,
            movable: movable,
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch
        ) { cell, model in
            cell.model = model
            cell.configure(withModel: model)
        }
    }

    public func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        cellProvider(tableView, indexPath)
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

@MainActor
final class TableViewCellRegistrar<Cell: UITableViewCell> {

    let reuseIdentifier: String
    private var registeredTableViews = Set<ObjectIdentifier>()

    init(reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
    }

    func registerIfNeeded(on tableView: UITableView) {
        let identifier = ObjectIdentifier(tableView)

        if registeredTableViews.contains(identifier) == false {
            tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
            registeredTableViews.insert(identifier)
        }
    }
}
