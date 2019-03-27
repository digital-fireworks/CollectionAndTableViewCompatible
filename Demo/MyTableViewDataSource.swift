//
//  MyTableViewData.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

enum Sections: Int {
    case UserSection
    case GenreSection
}

class MyTableViewDataSource: TableViewDataSource {
    
    let user: User
    let genres: [Genre]

    init(user: User, andGenres genres: [Genre], tableView: UITableView) {
        self.user = user
        self.genres = genres
        super.init(tableView: tableView)
    }
    
    func prepareData() {
        
        let userCellModel = UserCellModel(user: user)
        
        var items = [TableViewCompatible]()
        
        for genre in self.genres {
            let genreCellModel = GenreCellModel(genre: genre)
            genreCellModel.selected = user.genres.contains(genre)
            items.append(genreCellModel)
        }
        
        let userSection = TableViewSection(sortOrder: Sections.UserSection.rawValue, items: [userCellModel]);
        
        let section = TableViewSection(sortOrder: Sections.GenreSection.rawValue, items: items, headerTitle: "Genres", footerTitle: nil)
        
        sections = [userSection, section].sorted {
            return $0.sortOrder < $1.sortOrder
        }
    }
    
}
