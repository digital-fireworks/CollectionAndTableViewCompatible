//
//  Configurable.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

/**
 Let your `UITableViewCell` conform to this protocol.
 */
protocol Configurable {
    
    associatedtype T
    var model: T? { get set }
    func configureWithModel(_ model: T)
    
}
