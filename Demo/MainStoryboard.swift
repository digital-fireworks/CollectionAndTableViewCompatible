//
//  MainStoryboard.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

struct MainStoryboard: Storyboard {
    
    static var name: String {
        return "Main"
    }
    
    static var bundle: Bundle? {
        return nil
    }
    
    static let SimpleCellIdentifier = "SimpleCell"
    static let UserCellIdentifier = "UserCell"
    static let GenreCellIdentifier = "GenreCell"
    
}
