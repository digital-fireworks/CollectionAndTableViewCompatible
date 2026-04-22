//
//  GenreTableViewCell.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class GenreTableViewCell: UITableViewCell, Configurable {
    
    @IBOutlet weak var label: UILabel!
    
    var model: GenreCellModel?
    private lazy var favoriteIndicatorView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .systemYellow
        return imageView
    }()
    
    func configure(withModel model: GenreCellModel) {

        self.model = model
        self.label.text = model.genre.description
        self.updateAccessory()

    }
    
    private func updateAccessory() {
        if let model = self.model {
            self.accessoryType = .none
            self.accessoryView = model.showsFavoriteIndicator ? favoriteIndicatorView : nil
        }
    }
}
