//
//  SimpleCell.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class SimpleTableViewCell: UITableViewCell, Configurable {
    
    @IBOutlet weak var label: UILabel!
    var model: SimpleCellModel?
    
    func configure(withModel model: SimpleCellModel) {
        self.model = model
        label.text = model.string
    }
    
}
