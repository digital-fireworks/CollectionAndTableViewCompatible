//
//  CollectionViewController.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {
    
    var data: MyCollectionViewDataSource!
    private var isGenresEditing = false
    private var isPerformingInteractiveMove = false
    private lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleReorderGesture(_:)))
        gestureRecognizer.minimumPressDuration = 0.25
        return gestureRecognizer
    }()
    private lazy var sortGenresBarButtonItem = UIBarButtonItem(
        title: "Sort",
        style: .plain,
        target: self,
        action: #selector(sortGenres)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = MyCollectionViewDataSource(store: .shared, collectionView: collectionView!)
        data.onChange = { [weak self] in
            self?.updateNavigationItems()
        }
        collectionView?.addGestureRecognizer(reorderGestureRecognizer)
        collectionView?.register(
            CollectionSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionSectionHeaderView.reuseIdentifier
        )
        data.apply(animated: false)
        updateNavigationItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        data.apply(animated: false)
        updateNavigationItems()
    }

    @objc private func toggleEditMode() {
        isGenresEditing.toggle()
        data.isEditingGenres = isGenresEditing
        data.apply(animated: true)
        updateNavigationItems()
    }

    @objc private func sortGenres() {
        guard data.areGenresSorted == false else {
            return
        }

        data.sortGenres()
    }

    @objc private func handleReorderGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let collectionView else {
            return
        }

        let location = gestureRecognizer.location(in: collectionView)

        switch gestureRecognizer.state {
        case .began:
            guard
                isGenresEditing,
                let indexPath = collectionView.indexPathForItem(at: location),
                indexPath.section == data.genreSectionIndex,
                data.collectionView(collectionView, canMoveItemAt: indexPath)
            else {
                return
            }

            isPerformingInteractiveMove = collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            guard isPerformingInteractiveMove else {
                return
            }
            collectionView.updateInteractiveMovementTargetPosition(location)
        case .ended:
            guard isPerformingInteractiveMove else {
                return
            }

            isPerformingInteractiveMove = false
            collectionView.endInteractiveMovement()
        default:
            guard isPerformingInteractiveMove else {
                return
            }

            isPerformingInteractiveMove = false
            collectionView.cancelInteractiveMovement()
        }
    }

    private func updateNavigationItems() {
        let systemItem: UIBarButtonItem.SystemItem = isGenresEditing ? .done : .edit
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: systemItem,
            target: self,
            action: #selector(toggleEditMode)
        )
        sortGenresBarButtonItem.isEnabled = data.areGenresSorted == false
        navigationItem.rightBarButtonItem = sortGenresBarButtonItem
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        guard
            isGenresEditing,
            originalIndexPath.section == data.genreSectionIndex,
            proposedIndexPath.section == data.genreSectionIndex
        else {
            return originalIndexPath
        }

        return proposedIndexPath
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard data.numberOfItemsInSection(section: section) > 0 else {
            return .zero
        }

        return CGSize(width: collectionView.bounds.width, height: 36)
    }
}

final class CollectionSectionHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "CollectionSectionHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
