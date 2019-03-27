//
//  UserCollectionViewCell.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class UserCollectionViewCell: UICollectionViewCell, Configurable {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var model: UserCellModel?
    
    func configure(withModel model: UserCellModel) {
        self.model = model
        userImageView.image = UIImage(named: model.imageName)
        userNameLabel.text = model.userName
    }
}
