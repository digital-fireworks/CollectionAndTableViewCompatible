//
//  Configurable.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

/**
 Let your `UICollectionViewCell` or `UITableViewCell` conform to this protocol.
 */
@MainActor
public protocol Configurable: AnyObject {
    
    associatedtype T
    var model: T? { get set }
    func configure(withModel model: T)
    
}
