# CollectionAndTableViewCompatible

`CollectionAndTableViewCompatible` is a UIKit-first library for reducing `UITableView` and `UICollectionView` boilerplate.

The intended flow is simple:

1. Create one model.
2. Tell that model which table-view cell and collection-view cell it uses.
3. Build sections from the same models.
4. Render those sections in UIKit or SwiftUI.

Swift Package Manager is the primary distribution path for this repo.

## Requirements

- Xcode 26 or newer
- iOS 15+

## Installation

Add the package in Xcode:

```text
https://github.com/jayway/CollectionAndTableViewCompatible
```

Then add the `CollectionAndTableViewCompatible` product to your target.

## Smallest Useful Example

### 1. Create One Model

```swift
import UIKit
import CollectionAndTableViewCompatible

struct Genre: Identifiable, Hashable, TableViewCellModel, CollectionViewCellModel {
    let id: UUID
    let name: String

    typealias Cell = GenreTableViewCell
    typealias CollectionCell = GenreCollectionViewCell
}
```

### 2. Implement The Two Cells

No Auto Layout is required for the example. Use cells with built-in content configurations.

```swift
import UIKit
import CollectionAndTableViewCompatible

final class GenreTableViewCell: UITableViewCell, Configurable {
    var model: Genre?

    func configure(withModel model: Genre) {
        var content = defaultContentConfiguration()
        content.text = model.name
        contentConfiguration = content
    }
}

final class GenreCollectionViewCell: UICollectionViewListCell, Configurable {
    var model: Genre?

    func configure(withModel model: Genre) {
        var content = defaultContentConfiguration()
        content.text = model.name
        contentConfiguration = content
    }
}
```

### 3. Build Table And Collection Sections From The Same Models

```swift
let genres = [
    Genre(id: UUID(), name: "Rock"),
    Genre(id: UUID(), name: "Jazz"),
    Genre(id: UUID(), name: "Pop"),
]

let tableSections = [
    TableSection("Genres", id: "genres") {
        genres.map { $0.tableViewCell() }
    }
]

let collectionSections = [
    CollectionViewCellSection(id: "genres") {
        genres.map { $0.collectionViewCell() }
    }
]
```

That is the core value proposition of the library: one model can drive both a table view and a collection view.

## Table Swipe Actions

Swipe actions are added on the `TableViewCell` descriptor, not on the model itself.

Assume a `store` object owns your `genres` array and can rebuild the current sections.

```swift
TableSection("Genres", id: "genres") {
    store.genres.map { genre in
        genre
            .tableViewCell()
            .trailingSwipeActions {
                TableRowAction("Favorite", systemImage: "star.fill") { context in
                    store.favorites.insert(genre.id)
                    context.refresh()
                }

                TableRowAction("Delete", role: .destructive) { context in
                    store.genres.removeAll { $0.id == genre.id }
                    context.apply(store.makeTableSections())
                }
            }
    }
}
```

The important parts are:

- Use `.leadingSwipeActions { ... }` or `.trailingSwipeActions { ... }` on a `TableViewCell`.
- Add one or more `TableRowAction` values inside the builder.
- Each action gets a `TableRowContext`.
- `context.refresh()` reconfigures the current row.
- `context.apply(...)` replaces the current table sections, which is what you usually want after inserts, deletes, moves, or section changes.

If you want the standard edit-mode delete flow, use `.onDelete { ... }` instead:

```swift
genre
    .tableViewCell()
    .editable()
    .onDelete { context in
        store.genres.removeAll { $0.id == genre.id }
        context.apply(store.makeTableSections())
    }
```

`onDelete` is for UIKit's edit/delete behavior. `leadingSwipeActions` and `trailingSwipeActions` are for custom swipe buttons. Custom swipe actions are suppressed while the table view is in edit mode so UIKit can use its normal delete UI.

## SwiftUI

Both list surfaces can be hosted directly in SwiftUI.

```swift
import SwiftUI
import CollectionAndTableViewCompatible

struct ContentView: View {
    @State private var genres = [
        Genre(id: UUID(), name: "Rock"),
        Genre(id: UUID(), name: "Jazz"),
        Genre(id: UUID(), name: "Pop"),
    ]

    var body: some View {
        TabView {
            TableListView {
                TableSection("Genres", id: "genres") {
                    genres.map { $0.tableViewCell() }
                }
            }
            .tabItem { Label("Table", systemImage: "list.bullet") }

            CollectionListView(layout: .list()) {
                CollectionViewCellSection(id: "genres") {
                    genres.map { $0.collectionViewCell() }
                }
            }
            .tabItem { Label("Collection", systemImage: "square.grid.2x2") }
        }
    }
}
```

As long as your section ids and cell ids stay stable, updates from SwiftUI state animate automatically.

## Collection Layouts

The built-in collection wrapper supports simple default layouts:

```swift
CollectionListView(layout: .list())
CollectionListView(layout: .grid(columns: 2))
CollectionListView(layout: .adaptive(minimumItemWidth: 160))
```

You can also provide a custom `UICollectionViewLayout`:

```swift
CollectionListView(layout: .custom {
    UICollectionViewFlowLayout()
})
```

## Notes

- `TableListView` and `CollectionListView` are the simplest modern entry points.
- `TableSection` and `CollectionViewCellSection` are identity-based and intended for diffable updates.
- Older compatibility APIs such as `TableViewCompatible`, `CollectionViewCompatible`, `TableViewDataSource`, and `CollectionViewDataSource` are still in the repo.
- CocoaPods and Carthage files remain for legacy consumers, but SPM is the maintained path.

## Author

- `Fredrik Nannestad, fredrik.nannestad@jayway.com - Main author`
- `Jimmie Jensen, jimmie.jensen@jayway.com - Contributor`

## License

CollectionAndTableViewCompatible is available under the Apache License Version 2.0. See the LICENSE file for more info.
