//
//  MyCollectionViewDataSource.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit
import CollectionAndTableViewCompatible

class MyCollectionViewDataSource: CollectionViewDataSource {
    
    let user: User
    let genres: [Genre]
    
    init(user: User, andGenres genres: [Genre], collectionView: UICollectionView) {
        self.user = user
        self.genres = genres
        super.init(collectionView: collectionView)
    }

    func prepareData() {
        
        let userCellModel = UserCellModel(user: user)
        
        var items = [CollectionViewCompatible]()
        
        for genre in self.genres {
            let genreCellModel = GenreCellModel(genre: genre)
            genreCellModel.selected = user.genres.contains(genre)
            items.append(genreCellModel)
        }
        
        let userSection = CollectionViewSection(sortOrder: Sections.UserSection.rawValue, items: [userCellModel]);
        
        let section = CollectionViewSection(sortOrder: Sections.GenreSection.rawValue, items: items)
        
        sections = [userSection, section].sorted {
            return $0.sortOrder < $1.sortOrder
        }
    }
    
}
