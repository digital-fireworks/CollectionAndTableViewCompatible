//
//  Storyboard.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

protocol Storyboard {
    
    static var name: String { get }
    static var bundle: Bundle? { get }
    static var instance: UIStoryboard { get }
    
}

extension Storyboard {
    static var instance: UIStoryboard {
        return UIStoryboard(name: Self.name, bundle: Self.bundle)
    }
}
