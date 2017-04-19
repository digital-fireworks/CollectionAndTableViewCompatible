//
//  DisplayCycle.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

public protocol DisplayCycle {
    
    func willDisplay()
    
    func didEndDisplay()
    
}

extension UITableViewCell: DisplayCycle {
    
    public func willDisplay() { }
    
    public func didEndDisplay() { }
    
}

extension UICollectionViewCell: DisplayCycle {
    
    public func willDisplay() { }
    
    public func didEndDisplay() { }
    
}
