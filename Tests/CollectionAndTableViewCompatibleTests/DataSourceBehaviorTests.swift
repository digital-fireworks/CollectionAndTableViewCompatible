import Testing
import UIKit
@testable import CollectionAndTableViewCompatible
#if canImport(SwiftUI)
import SwiftUI
#endif

@MainActor
struct DataSourceBehaviorTests {
    @Test("Table view subscript setter replaces the item at an index path")
    func tableViewSubscriptSetterReplacesItem() {
        var dataSource = TableViewDataSource(tableView: UITableView(frame: .zero, style: .plain))
        let original = TrackingTableItem()
        let replacement = TrackingTableItem()
        let indexPath = IndexPath(row: 0, section: 0)

        dataSource.sections = [
            TableViewSection(sortOrder: 0, items: [original])
        ]

        dataSource[indexPath] = replacement

        #expect((dataSource[indexPath] as? TrackingTableItem) === replacement)
        #expect(dataSource.sections[0].items.count == 1)
    }

    @Test("Collection view subscript setter replaces the item at an index path")
    func collectionViewSubscriptSetterReplacesItem() {
        let layout = UICollectionViewFlowLayout()
        var dataSource = CollectionViewDataSource(collectionView: UICollectionView(frame: .zero, collectionViewLayout: layout))
        let original = TrackingCollectionItem()
        let replacement = TrackingCollectionItem()
        let indexPath = IndexPath(row: 0, section: 0)

        dataSource.sections = [
            CollectionViewSection(sortOrder: 0, items: [original])
        ]

        dataSource[indexPath] = replacement

        #expect((dataSource[indexPath] as? TrackingCollectionItem) === replacement)
        #expect(dataSource.sections[0].items.count == 1)
    }

    @Test("Table prefetch forwarding ignores invalid cancellation index paths")
    func tablePrefetchCancellationGuardsBounds() {
        let item = TrackingTableItem()
        let dataSource = TableViewDataSource(tableView: UITableView(frame: .zero, style: .plain))

        dataSource.sections = [
            TableViewSection(sortOrder: 0, items: [item])
        ]

        dataSource.prefetchObjectsAtIndexPaths(indexPaths: [IndexPath(row: 0, section: 0)])
        dataSource.cancelPrefetchingObjectsAtIndexPaths(indexPaths: [
            IndexPath(row: 0, section: 0),
            IndexPath(row: 1, section: 0),
            IndexPath(row: 0, section: 1),
        ])

        #expect(item.prefetchCallCount == 1)
        #expect(item.cancelPrefetchCallCount == 1)
    }

    @Test("Collection move updates item order within a section")
    func collectionMoveReordersItems() {
        let layout = UICollectionViewFlowLayout()
        let dataSource = CollectionViewDataSource(collectionView: UICollectionView(frame: .zero, collectionViewLayout: layout))
        let first = TrackingCollectionItem()
        let second = TrackingCollectionItem()

        dataSource.sections = [
            CollectionViewSection(sortOrder: 0, items: [first, second])
        ]

        dataSource.moveItem(atIndexPath: IndexPath(row: 0, section: 0), toIndexPath: IndexPath(row: 1, section: 0))

        #expect((dataSource[IndexPath(row: 0, section: 0)] as? TrackingCollectionItem) === second)
        #expect((dataSource[IndexPath(row: 1, section: 0)] as? TrackingCollectionItem) === first)
    }

    @Test("Table move target stays at source when the destination item is not movable")
    func tableMoveTargetRejectsNonMovableDestination() {
        let dataSource = TableViewDataSource(tableView: UITableView(frame: .zero, style: .plain))
        let source = TrackingTableItem(movable: true)
        let destination = TrackingTableItem(movable: false)
        let sourceIndexPath = IndexPath(row: 0, section: 0)
        let destinationIndexPath = IndexPath(row: 1, section: 0)

        dataSource.sections = [
            TableViewSection(sortOrder: 0, items: [source, destination])
        ]

        let resolved = dataSource.tableView(
            dataSource.tableView,
            targetIndexPathForMoveFromRowAt: sourceIndexPath,
            toProposedIndexPath: destinationIndexPath
        )

        #expect(resolved == sourceIndexPath)
    }

    @Test("Table row registration configures a typed cell without a reuse identifier")
    func tableRowRegistrationConfiguresCell() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let row = TableViewRow(cellType: ModernTableCell.self, model: "Taylor")

        let cell = row.cell(for: tableView, at: IndexPath(row: 0, section: 0)) as? ModernTableCell

        #expect(cell?.model == "Taylor")
        #expect(cell?.configuredValue == "Taylor")
        #expect(row.model(as: String.self) == "Taylor")
    }

    @Test("Collection item registration configures a typed cell without a reuse identifier")
    func collectionItemRegistrationConfiguresCell() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let item = CollectionViewItem(cellType: ModernCollectionCell.self, model: "Swift")

        let cell = item.cell(for: collectionView, at: IndexPath(row: 0, section: 0)) as? ModernCollectionCell

        #expect(cell?.model == "Swift")
        #expect(cell?.configuredValue == "Swift")
        #expect(item.model(as: String.self) == "Swift")
    }

    @Test("Table row can use a typed reuse identifier for storyboard or manual registration flows")
    func tableRowReuseIdentifierConfiguresCell() {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ModernTableCell.self, forCellReuseIdentifier: "ModernTableCell")

        let row = TableViewRow(
            cellType: ModernTableCell.self,
            model: "Row",
            reuseIdentifier: "ModernTableCell"
        )

        let cell = row.cell(for: tableView, at: IndexPath(row: 0, section: 0)) as? ModernTableCell

        #expect(cell?.model == "Row")
        #expect(cell?.configuredValue == "Row")
    }

    @Test("Diffable table list applies section and row counts")
    func tableListAdapterAppliesDiffableSnapshot() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let adapter = TableListAdapter(tableView: tableView)

        adapter.apply([
            TableSection(id: "settings", rows: [
                TableRow(id: "profile", model: "Profile", cell: ModernTableCell.self),
                TableRow(id: "notifications", model: "Notifications", cell: ModernTableCell.self),
            ])
        ], animated: false)

        #expect(tableView.numberOfSections == 1)
        #expect(tableView.numberOfRows(inSection: 0) == 2)
    }

    @Test("Reapplying a diffable row with the same identity uses the latest row definition")
    func tableListAdapterReappliesLatestRowDefinition() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let adapter = TableListAdapter(tableView: tableView)
        let indexPath = IndexPath(row: 0, section: 0)

        adapter.apply([
            TableSection(id: "section", rows: [
                TableRow(id: "row", model: "Old", cell: ModernTableCell.self)
            ])
        ], animated: false)

        adapter.apply([
            TableSection(id: "section", rows: [
                TableRow(id: "row", model: "New", cell: ModernTableCell.self)
            ])
        ], animated: false)

        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as? ModernTableCell

        #expect(cell?.model == "New")
        #expect(cell?.configuredValue == "New")
    }

    @Test("Table view render builder creates and applies a list adapter automatically")
    func tableViewRenderBuilderAppliesSections() {
        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.render(animated: false) {
            TableSection("Settings", id: "settings") {
                TableRow(id: "profile", model: "Profile", cell: ModernTableCell.self)
            }
        }

        #expect(tableView.numberOfSections == 1)
        #expect(tableView.numberOfRows(inSection: 0) == 1)
    }

    @Test("Table section can sort rows by their typed model")
    func tableSectionSortedRowsUsesTypedModelComparator() {
        let section = TableSection(id: "settings", rows: [
            TableRow(id: "beta", model: "Beta", cell: ModernTableCell.self),
            TableRow(id: "alpha", model: "Alpha", cell: ModernTableCell.self),
        ])
        .sortedRows(as: String.self) { lhs, rhs in
            lhs.localizedStandardCompare(rhs) == .orderedAscending
        }

        let sortedValues = section.rows.compactMap { $0.model(as: String.self) }

        #expect(sortedValues == ["Alpha", "Beta"])
    }

    @Test("Table row exposes trailing swipe actions through the delegate bridge")
    func tableRowSwipeActionsReachTheDelegate() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let adapter = TableListAdapter(tableView: tableView)

        adapter.apply([
            TableSection(id: "actions", rows: [
                TableRow(id: "favorite", model: "Favorite", cell: ModernTableCell.self)
                    .trailingSwipeActions {
                        TableRowAction("Delete", role: .destructive) { _ in }
                    }
            ])
        ], animated: false)

        let configuration = tableView.delegate?.tableView?(
            tableView,
            trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
        )

        #expect(configuration?.actions.count == 1)
        #expect(configuration?.performsFirstActionWithFullSwipe == true)
    }

    @Test("Edit mode suppresses custom trailing swipe actions so UIKit can use the default delete flow")
    func editModeSuppressesCustomSwipeActions() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let adapter = TableListAdapter(tableView: tableView)

        adapter.apply([
            TableSection(id: "actions", rows: [
                TableRow(id: "favorite", model: "Favorite", cell: ModernTableCell.self)
                    .editable()
                    .trailingSwipeActions {
                        TableRowAction("Favorite") { _ in }
                    }
            ])
        ], animated: false)

        tableView.isEditing = true

        let configuration = tableView.delegate?.tableView?(
            tableView,
            trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
        )

        #expect(configuration == nil)
    }

    @Test("Table row marked movable is exposed as movable by the diffable data source")
    func tableRowMovableStateReachesTheDataSource() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let adapter = TableListAdapter(tableView: tableView)
        let indexPath = IndexPath(row: 0, section: 0)

        adapter.apply([
            TableSection(id: "reorder", rows: [
                TableRow(id: "row", model: "Reorder", cell: ModernTableCell.self)
                    .movable()
            ])
        ], animated: false)

        let canMove = tableView.dataSource?.tableView?(tableView, canMoveRowAt: indexPath)

        #expect(canMove == true)
    }

    @Test("Table row move handler receives source and destination index paths")
    func tableRowMoveHandlerReceivesIndices() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let adapter = TableListAdapter(tableView: tableView)
        var recordedMove: (IndexPath, IndexPath)?

        adapter.apply([
            TableSection(id: "moves", rows: [
                TableRow(id: "first", model: "First", cell: ModernTableCell.self),
                TableRow(id: "second", model: "Second", cell: ModernTableCell.self)
                    .onMove { source, destination in
                        recordedMove = (source, destination)
                    },
            ])
        ], animated: false)

        adapter.moveRow(from: IndexPath(row: 1, section: 0), to: IndexPath(row: 0, section: 0))

        #expect(recordedMove?.0 == IndexPath(row: 1, section: 0))
        #expect(recordedMove?.1 == IndexPath(row: 0, section: 0))
    }

    @Test("Table row model protocol creates a typed row from an identifiable model")
    func tableRowModelProtocolCreatesTypedRow() {
        let model = IdentifiedName(id: 7, name: "Morgan")
        let row = model.tableViewCell()
        let tableView = UITableView(frame: .zero, style: .plain)

        let cell = row.cell(for: tableView, at: IndexPath(row: 0, section: 0)) as? IdentifiedNameCell

        #expect(cell?.configuredValue?.name == "Morgan")
        #expect(row.id == TableIdentifier(7))
    }

    @Test("Collection cell model protocol creates a typed cell from a configurable model")
    func collectionCellModelProtocolCreatesTypedCell() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(IdentifiedCollectionNameCell.self, forCellWithReuseIdentifier: "IdentifiedCollectionNameCell")

        let model = IdentifiedCollectionName(name: "Jamie")
        let item = model.collectionViewCell(
            id: model.id,
            reuseIdentifier: "IdentifiedCollectionNameCell",
            movable: true
        )

        let cell = item.cell(for: collectionView, at: IndexPath(row: 0, section: 0)) as? IdentifiedCollectionNameCell

        #expect(cell?.configuredValue?.name == "Jamie")
        #expect(item.model(as: IdentifiedCollectionName.self)?.name == "Jamie")
        #expect(item.movable == true)
    }

    #if canImport(SwiftUI)
    @Test("SwiftUI table list view can be initialized from diffable sections")
    func swiftUITableListViewInitializes() {
        let sections = [
            TableSection(id: "swiftui", rows: [
                TableRow(id: "row", model: "Hosted", cell: ModernTableCell.self)
            ])
        ]

        let view = TableListView(sections: sections, animated: false)

        _ = view
        #expect(sections.count == 1)
    }

    @Test("SwiftUI collection list view can be initialized from diffable sections")
    func swiftUICollectionListViewInitializes() {
        let sections = [
            CollectionViewCellSection(id: "swiftui") {
                CollectionViewCell(id: "row", cellType: ModernCollectionCell.self, model: "Hosted")
            }
        ]

        let view = CollectionListView(layout: .grid(columns: 2), sections: sections, animated: false)

        _ = view
        #expect(sections.count == 1)
    }
    #endif
}

private final class TrackingTableItem: TableViewCompatible {
    let movableValue: Bool
    var selected = false
    var prefetchCallCount = 0
    var cancelPrefetchCallCount = 0

    init(movable: Bool = false) {
        self.movableValue = movable
    }

    var reuseIdentifier: String {
        "TrackingTableItem"
    }

    var movable: Bool {
        movableValue
    }

    func prefetch() {
        prefetchCallCount += 1
    }

    func cancelPrefetch() {
        cancelPrefetchCallCount += 1
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
    }
}

private final class TrackingCollectionItem: CollectionViewCompatible {
    let movableValue: Bool
    var selected = false
    var prefetchCallCount = 0
    var cancelPrefetchCallCount = 0

    init(movable: Bool = false) {
        self.movableValue = movable
    }

    var reuseIdentifier: String {
        "TrackingCollectionItem"
    }

    var movable: Bool {
        movableValue
    }

    func prefetch() {
        prefetchCallCount += 1
    }

    func cancelPrefetch() {
        cancelPrefetchCallCount += 1
    }

    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell(frame: .zero)
    }
}

private final class ModernTableCell: UITableViewCell, Configurable {
    var model: String?
    var configuredValue: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(withModel model: String) {
        configuredValue = model
    }
}

private final class ModernCollectionCell: UICollectionViewCell, Configurable {
    var model: String?
    var configuredValue: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(withModel model: String) {
        configuredValue = model
    }
}

private struct IdentifiedName: Identifiable, TableViewCellModel {
    let id: Int
    let name: String
    typealias Cell = IdentifiedNameCell
}

private final class IdentifiedNameCell: UITableViewCell, Configurable {
    var model: IdentifiedName?
    var configuredValue: IdentifiedName?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(withModel model: IdentifiedName) {
        configuredValue = model
    }
}

private struct IdentifiedCollectionName: Identifiable, CollectionViewCellModel {
    let id = UUID()
    let name: String
    typealias CollectionCell = IdentifiedCollectionNameCell
}

private final class IdentifiedCollectionNameCell: UICollectionViewCell, Configurable {
    var model: IdentifiedCollectionName?
    var configuredValue: IdentifiedCollectionName?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(withModel model: IdentifiedCollectionName) {
        configuredValue = model
    }
}
