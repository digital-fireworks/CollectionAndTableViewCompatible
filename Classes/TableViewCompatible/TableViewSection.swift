//
//  TableViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

public class TableViewSection {
    
    public var sortOrder: Int
    public var items: [TableViewCompatible]
    public var headerTitle: String?
    public var footerTitle: String?
    
    public init(sortOrder: Int, items: [TableViewCompatible], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.sortOrder = sortOrder
        self.items = items
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }
    
}
