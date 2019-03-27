//
//  User.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

class User {
    
    let name: String
    let imageName: String
    
    var genres: [Genre] = []
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
    
}
