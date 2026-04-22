//
//  TableViewDataSource.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 17/11/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit
import ObjectiveC
#if canImport(SwiftUI)
import SwiftUI
#endif

@MainActor
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
        self.numberOfRowsInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cellForTableView(tableView: tableView, atIndexPath: indexPath)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        self.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.titleForHeaderInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.titleForFooterInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        self[indexPath].editable
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        self[indexPath].movable
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
            break
        }
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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
        let proposedSection = proposedDestinationIndexPath.section
        let proposedRow = proposedDestinationIndexPath.row

        let cellToReplace: TableViewCompatible?

        if proposedSection >= self.sections.count {
            cellToReplace = self.sections.last?.items.last
        } else if proposedRow >= self.sections[proposedSection].items.count {
            cellToReplace = self.sections[proposedSection].items.last
        } else {
            cellToReplace = self[proposedDestinationIndexPath]
        }

        if let cellToReplace = cellToReplace, cellToReplace.movable {
            return proposedDestinationIndexPath
        } else {
            return sourceIndexPath
        }
    }
}

@MainActor
open class TableViewRowDataSource: NSObject, TableViewRowData, UITableViewDataSource {

    public let tableView: UITableView
    open var sections: [TableViewRowSection] = []

    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.prefetchDataSource = self
        }
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.numberOfRowsInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cellForTableView(tableView: tableView, atIndexPath: indexPath)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        self.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.titleForHeaderInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.titleForFooterInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        self[indexPath].editable
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        self[indexPath].movable
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
            break
        }
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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

extension TableViewRowDataSource: UITableViewDataSourcePrefetching {

    open func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        self.prefetchObjectsAtIndexPaths(indexPaths: indexPaths)
    }

    open func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        self.cancelPrefetchingObjectsAtIndexPaths(indexPaths: indexPaths)
    }
}

extension TableViewRowDataSource: UITableViewDelegate {

    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let proposedSection = proposedDestinationIndexPath.section
        let proposedRow = proposedDestinationIndexPath.row

        let rowToReplace: TableViewRow?

        if proposedSection >= self.sections.count {
            rowToReplace = self.sections.last?.items.last
        } else if proposedRow >= self.sections[proposedSection].items.count {
            rowToReplace = self.sections[proposedSection].items.last
        } else {
            rowToReplace = self[proposedDestinationIndexPath]
        }

        if let rowToReplace = rowToReplace, rowToReplace.movable {
            return proposedDestinationIndexPath
        } else {
            return sourceIndexPath
        }
    }
}

@MainActor
public final class TableListAdapter: NSObject, UITableViewDataSourcePrefetching {

    public let tableView: UITableView
    public private(set) var sections: [TableSection] = []

    public var defaultRowAnimation: UITableView.RowAnimation {
        get { dataSource.defaultRowAnimation }
        set { dataSource.defaultRowAnimation = newValue }
    }

    private lazy var dataSource = DiffableTableDataSource(tableView: tableView, owner: self)
    private lazy var delegateProxy = TableListDelegateProxy(owner: self)
    private var rowsByIdentifier: [TableListItemIdentifier: TableRow] = [:]
    private var sectionsByIdentifier: [TableIdentifier: TableSection] = [:]

    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = dataSource
        tableView.delegate = delegateProxy
        tableView.prefetchDataSource = self
    }

    public func apply(_ sections: [TableSection], animated: Bool = true) {
        validateIdentifiers(in: sections)

        let previousIdentifiers = Set(rowsByIdentifier.keys)
        let newRows = makeRowLookup(from: sections)

        self.sections = sections
        self.rowsByIdentifier = newRows
        self.sectionsByIdentifier = Dictionary(uniqueKeysWithValues: sections.map { ($0.id, $0) })

        var snapshot = NSDiffableDataSourceSnapshot<TableIdentifier, TableListItemIdentifier>()
        let sectionIdentifiers = sections.map(\.id)
        snapshot.appendSections(sectionIdentifiers)

        for section in sections {
            let identifiers = section.rows.map { TableListItemIdentifier(sectionID: section.id, rowID: $0.id) }
            snapshot.appendItems(identifiers, toSection: section.id)
        }

        let commonIdentifiers = snapshot.itemIdentifiers.filter(previousIdentifiers.contains)
        if commonIdentifiers.isEmpty == false {
            snapshot.reconfigureItems(commonIdentifiers)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            row(at: indexPath)?.prefetch()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            row(at: indexPath)?.cancelPrefetch()
        }
    }

    func section(at index: Int) -> TableSection? {
        guard sections.indices.contains(index) else {
            return nil
        }

        return sections[index]
    }

    func row(at indexPath: IndexPath) -> TableRow? {
        guard let identifier = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        return rowsByIdentifier[identifier]
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let destinationRow = fallbackRow(for: proposedDestinationIndexPath) else {
            return sourceIndexPath
        }

        return destinationRow.isMovable ? proposedDestinationIndexPath : sourceIndexPath
    }

    func didSelectRow(at indexPath: IndexPath) {
        guard
            let identifier = dataSource.itemIdentifier(for: indexPath),
            let context = context(for: identifier, fallbackIndexPath: indexPath)
        else {
            return
        }

        context.row.performSelection(with: context)
        refreshIfPresent(identifier, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func swipeActionsConfiguration(for indexPath: IndexPath, edge: TableRowSwipeEdge) -> UISwipeActionsConfiguration? {
        guard tableView.isEditing == false else {
            return nil
        }

        guard
            let identifier = dataSource.itemIdentifier(for: indexPath),
            let row = rowsByIdentifier[identifier]
        else {
            return nil
        }

        let actions = row.swipeActions(for: edge)
        guard actions.isEmpty == false else {
            return nil
        }

        let contextualActions = actions.actions.map { action in
            let style: UIContextualAction.Style = action.role == .destructive ? .destructive : .normal
            let contextualAction = UIContextualAction(style: style, title: action.title) { [unowned self] _, _, completion in
                guard let context = self.context(for: identifier, fallbackIndexPath: indexPath) else {
                    completion(false)
                    return
                }

                action.perform(with: context)
                self.refreshIfPresent(identifier, animated: true)
                completion(true)
            }

            if let systemImage = action.systemImage {
                contextualAction.image = UIImage(systemName: systemImage)
            }

            contextualAction.backgroundColor = action.backgroundColor
            return contextualAction
        }

        let configuration = UISwipeActionsConfiguration(actions: contextualActions)
        configuration.performsFirstActionWithFullSwipe = actions.allowsFullSwipe
        return configuration
    }

    func commit(_ editingStyle: UITableViewCell.EditingStyle, for indexPath: IndexPath) {
        guard
            editingStyle == .delete,
            let identifier = dataSource.itemIdentifier(for: indexPath),
            let context = context(for: identifier, fallbackIndexPath: indexPath),
            let row = rowsByIdentifier[identifier]
        else {
            return
        }

        if row.hasDeleteHandler {
            row.performDelete(with: context)
            refreshIfPresent(identifier, animated: true)
        } else {
            var updatedSections = sections
            updatedSections[indexPath.section].rows.remove(at: indexPath.row)
            apply(updatedSections, animated: true)
        }
    }

    func moveRow(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var updatedSections = sections
        let row = updatedSections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.row)
        row.performMove(from: sourceIndexPath, to: destinationIndexPath)
        updatedSections[destinationIndexPath.section].rows.insert(row, at: destinationIndexPath.row)
        apply(updatedSections, animated: false)
    }

    private func fallbackRow(for indexPath: IndexPath) -> TableRow? {
        if let row = row(at: indexPath) {
            return row
        }

        if indexPath.section >= sections.count {
            return sections.last?.rows.last
        }

        if indexPath.row >= sections[indexPath.section].rows.count {
            return sections[indexPath.section].rows.last
        }

        return nil
    }

    private func context(for identifier: TableListItemIdentifier, fallbackIndexPath: IndexPath? = nil) -> TableRowContext? {
        guard
            let row = rowsByIdentifier[identifier],
            let section = sectionsByIdentifier[identifier.sectionID]
        else {
            return nil
        }

        guard let indexPath = dataSource.indexPath(for: identifier) ?? fallbackIndexPath else {
            return nil
        }

        return TableRowContext(
            tableView: tableView,
            indexPath: indexPath,
            section: section,
            row: row,
            refreshHandler: { [weak self] animated in
                self?.refreshIfPresent(identifier, animated: animated)
            },
            applyHandler: { [weak self] sections, animated in
                self?.apply(sections, animated: animated)
            }
        )
    }

    private func refreshIfPresent(_ identifier: TableListItemIdentifier, animated: Bool) {
        guard rowsByIdentifier[identifier] != nil else {
            return
        }

        var snapshot = dataSource.snapshot()
        guard snapshot.itemIdentifiers.contains(identifier) else {
            return
        }

        snapshot.reconfigureItems([identifier])
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func makeRowLookup(from sections: [TableSection]) -> [TableListItemIdentifier: TableRow] {
        var lookup: [TableListItemIdentifier: TableRow] = [:]

        for section in sections {
            for row in section.rows {
                lookup[TableListItemIdentifier(sectionID: section.id, rowID: row.id)] = row
            }
        }

        return lookup
    }

    private func validateIdentifiers(in sections: [TableSection]) {
        var seenSections = Set<TableIdentifier>()

        for section in sections {
            precondition(
                seenSections.insert(section.id).inserted,
                "Duplicate TableSection id '\(section.id)' found. Section ids must be unique."
            )

            var seenRows = Set<TableIdentifier>()

            for row in section.rows {
                precondition(
                    seenRows.insert(row.id).inserted,
                    "Duplicate TableRow id '\(row.id)' found in section '\(section.id)'. Row ids must be unique within their section."
                )
            }
        }
    }
}

@MainActor
public extension UITableView {

    var tableListAdapter: TableListAdapter {
        if let adapter = objc_getAssociatedObject(self, &tableListAdapterKey) as? TableListAdapter {
            return adapter
        }

        let adapter = TableListAdapter(tableView: self)
        objc_setAssociatedObject(self, &tableListAdapterKey, adapter, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return adapter
    }

    func apply(_ sections: [TableSection], animated: Bool = true) {
        tableListAdapter.apply(sections, animated: animated)
    }

    func render(animated: Bool = true, @TableSectionBuilder _ content: () -> [TableSection]) {
        apply(content(), animated: animated)
    }
}

@MainActor
public final class TableListViewController: UIViewController {

    public let tableView: UITableView
    public let tableListAdapter: TableListAdapter

    public init(style: UITableView.Style = .plain) {
        self.tableView = UITableView(frame: .zero, style: style)
        self.tableListAdapter = TableListAdapter(tableView: tableView)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = .clear

        tableView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: rootView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
        ])

        view = rootView
    }

    public func apply(_ sections: [TableSection], animated: Bool = true) {
        tableListAdapter.apply(sections, animated: animated)
    }
}

#if canImport(SwiftUI)
@MainActor
public struct TableListView: UIViewControllerRepresentable {

    public let style: UITableView.Style
    public let sections: [TableSection]
    public let animated: Bool

    public init(
        style: UITableView.Style = .plain,
        sections: [TableSection],
        animated: Bool = true
    ) {
        self.style = style
        self.sections = sections
        self.animated = animated
    }

    public init(
        style: UITableView.Style = .plain,
        animated: Bool = true,
        @TableSectionBuilder content: () -> [TableSection]
    ) {
        self.init(style: style, sections: content(), animated: animated)
    }

    public func makeUIViewController(context: Context) -> TableListViewController {
        let controller = TableListViewController(style: style)
        controller.apply(sections, animated: false)
        return controller
    }

    public func updateUIViewController(_ uiViewController: TableListViewController, context: Context) {
        uiViewController.apply(sections, animated: animated)
    }
}
#endif

private struct TableListItemIdentifier: Hashable, Sendable {
    let sectionID: TableIdentifier
    let rowID: TableIdentifier
}

@MainActor
private final class DiffableTableDataSource: UITableViewDiffableDataSource<TableIdentifier, TableListItemIdentifier> {

    unowned let owner: TableListAdapter

    init(tableView: UITableView, owner: TableListAdapter) {
        self.owner = owner
        super.init(tableView: tableView) { [unowned owner] tableView, indexPath, identifier in
            owner.row(at: indexPath)?.cell(for: tableView, at: indexPath)
        }
        defaultRowAnimation = .automatic
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        owner.section(at: section)?.headerTitle
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        owner.section(at: section)?.footerTitle
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        owner.row(at: indexPath)?.isEditable ?? false
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        owner.row(at: indexPath)?.isMovable ?? false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        owner.commit(editingStyle, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        owner.moveRow(from: sourceIndexPath, to: destinationIndexPath)
    }
}

@MainActor
private final class TableListDelegateProxy: NSObject, UITableViewDelegate {

    unowned let owner: TableListAdapter

    init(owner: TableListAdapter) {
        self.owner = owner
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        owner.didSelectRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.willDisplay()
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.didEndDisplay()
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        owner.tableView(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        owner.swipeActionsConfiguration(for: indexPath, edge: .leading)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        owner.swipeActionsConfiguration(for: indexPath, edge: .trailing)
    }
}

@MainActor
private var tableListAdapterKey: UInt8 = 0
