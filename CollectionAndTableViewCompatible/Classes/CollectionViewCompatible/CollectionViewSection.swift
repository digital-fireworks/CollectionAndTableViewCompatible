//
//  CollectionViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import Foundation

class CollectionViewSection: NSObject {
    
    var sortOrder: Int
    var items: [CollectionViewCompatible]
    
    init(sortOrder: Int, items: [CollectionViewCompatible]) {
        self.sortOrder = sortOrder
        self.items = items
    }
}
