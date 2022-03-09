//
//  TableViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

open class TableViewSection {
    
    open var sortOrder: Int
    open var items: [TableViewCompatible]
    open var headerTitle: String?
    open var footerTitle: String?
    
    public init(sortOrder: Int, items: [TableViewCompatible], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.sortOrder = sortOrder
        self.items = items
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }
    
}
