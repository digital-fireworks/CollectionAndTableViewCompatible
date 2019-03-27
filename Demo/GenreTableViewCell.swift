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

    private var observation: NSKeyValueObservation?
    
//    override func willDisplay() {
//        print(#function)
//    }
//    
//    override func didEndDisplay() {
//        print(#function)
//    }
    
    func configure(withModel model: GenreCellModel) {

        self.model = model
        self.label.text = model.genre.description

        // Remove previous observation
        self.observation = nil

        self.updateCheckmark()

        self.observation = model.observe(\.selected) { [unowned self] (model, change) in
            self.updateCheckmark()
        }

    }
    
    private func updateCheckmark() {
        if let model = self.model {
            self.accessoryType = model.selected ? .checkmark : .none
        }
    }
}
