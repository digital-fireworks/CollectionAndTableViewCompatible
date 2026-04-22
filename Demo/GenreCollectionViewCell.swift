//
//  GenreCollectionViewCell.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class GenreCollectionViewCell: UICollectionViewCell, Configurable {
    
    @IBOutlet weak var label: UILabel!
    
    var model: GenreCellModel?
    private lazy var favoriteIndicatorView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemYellow
        return imageView
    }()
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "star.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        return button
    }()
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(deleteGenre), for: .touchUpInside)
        return button
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(favoriteIndicatorView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            favoriteIndicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            favoriteIndicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            favoriteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
        ])
    }
    
    func configure(withModel model: GenreCellModel) {
        self.model = model
        self.label.text = model.genre.description
        updateEditingControls(for: model)
    }

    @objc private func toggleFavorite() {
        model?.onToggleFavorite?()
    }

    @objc private func deleteGenre() {
        model?.onDelete?()
    }

    private func updateEditingControls(for model: GenreCellModel) {
        let showsPassiveFavoriteIndicator = model.showsFavoriteIndicator && model.selected && model.isCollectionEditing == false

        favoriteIndicatorView.isHidden = showsPassiveFavoriteIndicator == false
        favoriteButton.isHidden = model.isCollectionEditing == false
        favoriteButton.isEnabled = model.isCollectionEditing
        deleteButton.isHidden = model.isCollectionEditing == false
        favoriteButton.tintColor = model.selected ? .systemYellow : .white
        let topInset: CGFloat = (model.isCollectionEditing || showsPassiveFavoriteIndicator) ? 28 : 8
        layoutMargins = UIEdgeInsets(top: topInset, left: 8, bottom: 8, right: 8)
    }

}
