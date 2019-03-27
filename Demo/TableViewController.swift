//
//  ViewController.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 21/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: AutolayoutTableView!
    var data: MyTableViewDataSource!
    var user: User = User(name: "Fredrik", imageName: "fredrik.jpg")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = MyTableViewDataSource(user: self.user, andGenres: Genre.allGenres, tableView: tableView)
        tableView.delegate = self
        data.prepareData()
        self.tableView.reloadData()
    }
    
    @IBAction func edit(sender: AnyObject!) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        updateLeftItem()
    }
    
    private func updateLeftItem() {
        let systemItem: UIBarButtonItem.SystemItem = self.isEditing ? .done : .edit
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(edit(sender:)))
    }

}
