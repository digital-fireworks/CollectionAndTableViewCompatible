//
//  SimpleCollectionViewCell.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class SimpleCollectionViewCell: UICollectionViewCell, Configurable {
    
    @IBOutlet weak var label: UILabel!
    var model: SimpleCellModel?
    
    func configure(withModel model: SimpleCellModel) {
        self.model = model
        label.text = model.string
    }
    
}
