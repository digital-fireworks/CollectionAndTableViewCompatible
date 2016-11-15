//
//  TableViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

protocol TableViewSection {
    
    var sortOrder: Int { get set }
    var items: [TableViewCompatible] { get set }
    var headerTitle: String? { get set }
    var footerTitle: String? { get set }
    
    init(sortOrder: Int, items: [TableViewCompatible], headerTitle: String?, footerTitle: String?)
    
}
