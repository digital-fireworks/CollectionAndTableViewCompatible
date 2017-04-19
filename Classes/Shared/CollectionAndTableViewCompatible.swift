//
//  CollectionAndTableViewCommons.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

public protocol CollectionAndTableViewCompatible {
    
    var reuseIdentifier: String { get }
    
    var selected: Bool { get set }
    var editable: Bool { get }
    var movable: Bool { get }
    
    func prefetch()
    func cancelPrefetch()

}

// Default implementations
public extension CollectionAndTableViewCompatible {
    
    public var editable: Bool {
        return false
    }
    
    public var movable: Bool {
        return false
    }
    
    public func prefetch() { }
    public func cancelPrefetch() { }
    
}
