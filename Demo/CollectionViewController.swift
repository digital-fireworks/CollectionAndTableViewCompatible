//
//  CollectionViewController.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {
    
    var data: MyCollectionViewDataSource!
    var user: User = User(name: "Fredrik", imageName: "fredrik.jpg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = MyCollectionViewDataSource(user: self.user, andGenres: Genre.allGenres, collectionView: collectionView!)
        data.prepareData()
        collectionView?.reloadData()
    
    }
    
}
