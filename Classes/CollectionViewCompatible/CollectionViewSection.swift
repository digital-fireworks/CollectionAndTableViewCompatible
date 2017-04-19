//
//  CollectionViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import Foundation

open class CollectionViewSection: NSObject {
    
    open var sortOrder: Int
    open var items: [CollectionViewCompatible]
    
    public init(sortOrder: Int, items: [CollectionViewCompatible]) {
        self.sortOrder = sortOrder
        self.items = items
    }
}
