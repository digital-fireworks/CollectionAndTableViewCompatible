//
//  GenreCell.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

@MainActor
enum GenreSectionID: String, Hashable {
    case favorites
    case genres
}

@MainActor
struct GenreSectionItemModel {
    let id: Genre
    let model: GenreCellModel
    let isMovable: Bool

    struct ContentState: Equatable {
        let isSelected: Bool
        let showsFavoriteIndicator: Bool
        let isCollectionEditing: Bool
    }

    var contentState: ContentState {
        ContentState(
            isSelected: model.selected,
            showsFavoriteIndicator: model.showsFavoriteIndicator,
            isCollectionEditing: model.isCollectionEditing
        )
    }
}

@MainActor
struct GenreSectionModel {
    let id: GenreSectionID
    let title: String
    let items: [GenreSectionItemModel]
}

@MainActor
final class GenreDemoStore {

    static let shared = GenreDemoStore(
        user: User(name: "Fredrik", imageName: "fredrik.jpg"),
        genres: Genre.allGenres
    )

    let user: User
    private(set) var genres: [Genre]

    init(user: User, genres: [Genre]) {
        self.user = user
        self.genres = Self.sortedGenres(genres)
    }

    var areGenresSorted: Bool {
        genres == Self.sortedGenres(genres)
    }

    @discardableResult
    func addGenre(named name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedName.isEmpty == false else {
            return false
        }

        let normalizedName = trimmedName.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let alreadyExists = genres.contains {
            $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) == normalizedName
        }

        guard alreadyExists == false else {
            return false
        }

        genres.append(Genre(trimmedName))
        return true
    }

    func sortGenres() {
        genres = Self.sortedGenres(genres)
    }

    func moveGenre(from sourceIndex: Int, to destinationIndex: Int) {
        guard
            genres.indices.contains(sourceIndex),
            genres.indices.contains(destinationIndex),
            sourceIndex != destinationIndex
        else {
            return
        }

        let movedGenre = genres.remove(at: sourceIndex)
        genres.insert(movedGenre, at: destinationIndex)
    }

    func makeSectionModels(isCollectionEditing: Bool, onChange: @escaping () -> Void) -> [GenreSectionModel] {
        var sectionModels = [GenreSectionModel]()

        let favoriteGenres = Self.sortedGenres(user.genres)
        if favoriteGenres.isEmpty == false {
            sectionModels.append(
                GenreSectionModel(
                    id: .favorites,
                    title: "Favorites",
                    items: favoriteGenres.map {
                        makeItemModel(
                            for: $0,
                            isCollectionEditing: isCollectionEditing,
                            isMovable: false,
                            onChange: onChange
                        )
                    }
                )
            )
        }

        sectionModels.append(
            GenreSectionModel(
                id: .genres,
                title: "Genres",
                items: genres.map {
                    makeItemModel(
                        for: $0,
                        isCollectionEditing: isCollectionEditing,
                        isMovable: true,
                        onChange: onChange
                    )
                }
            )
        )

        return sectionModels
    }

    private func makeItemModel(
        for genre: Genre,
        isCollectionEditing: Bool,
        isMovable: Bool,
        onChange: @escaping () -> Void
    ) -> GenreSectionItemModel {
        let genreCellModel = GenreCellModel(genre: genre)
        let isFavorite = user.genres.contains(genre)

        genreCellModel.selected = isFavorite
        genreCellModel.showsFavoriteIndicator = isFavorite
        genreCellModel.isCollectionEditing = isCollectionEditing
        genreCellModel.movable = isMovable
        genreCellModel.onToggleFavorite = { [weak self] in
            self?.toggleSelection(for: genre)
            onChange()
        }
        genreCellModel.onDelete = { [weak self] in
            self?.delete(genre: genre)
            onChange()
        }

        return GenreSectionItemModel(id: genre, model: genreCellModel, isMovable: isMovable)
    }

    private func toggleSelection(for genre: Genre) {
        if let index = user.genres.firstIndex(of: genre) {
            user.genres.remove(at: index)
        } else {
            user.genres.append(genre)
        }
    }

    private func delete(genre: Genre) {
        genres.removeAll { $0 == genre }
        user.genres.removeAll { $0 == genre }
    }

    private static func sortedGenres(_ genres: [Genre]) -> [Genre] {
        genres.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}

final class GenreCellModel: NSObject, TableViewCompatible, CollectionViewCompatible {

    var reuseIdentifier: String {
        MainStoryboard.GenreCellIdentifier
    }

    let genre: Genre

    @objc dynamic var selected: Bool = false
    var showsFavoriteIndicator = false
    var isCollectionEditing = false
    var onToggleFavorite: (() -> Void)?
    var onDelete: (() -> Void)?

    var editable: Bool = true
    var movable: Bool = true

    init(genre: Genre) {
        self.genre = genre
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! GenreTableViewCell
        cell.configure(withModel: self)
        return cell
    }

    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GenreCollectionViewCell
        cell.configure(withModel: self)
        return cell
    }

    func prefetch() {
        // Perform prefetching, for instance fetching data from the internet
    }

    func cancelPrefetch() {
        // Cancel any prefetching started in prefetch()
    }
}

extension GenreCellModel: TableViewCellModel, CollectionViewCellModel {
    typealias Cell = GenreTableViewCell
    typealias CollectionCell = GenreCollectionViewCell
}
