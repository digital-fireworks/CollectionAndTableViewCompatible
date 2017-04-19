//
//  CollectionViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import Foundation

public class CollectionViewSection: NSObject {
    
    public var sortOrder: Int
    public var items: [CollectionViewCompatible]
    
    public init(sortOrder: Int, items: [CollectionViewCompatible]) {
        self.sortOrder = sortOrder
        self.items = items
    }
}
