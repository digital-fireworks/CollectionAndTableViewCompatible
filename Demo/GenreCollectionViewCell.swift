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
    
    func configure(withModel model: GenreCellModel) {
        self.model = model
        self.label.text = model.genre.description
    }

}
