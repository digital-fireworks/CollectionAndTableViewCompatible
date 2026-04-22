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
    private var isGenresEditing = false
    private weak var addGenreAction: UIAlertAction?
    private lazy var addGenreBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addGenre)
    )
    private lazy var sortGenresBarButtonItem = UIBarButtonItem(
        title: "Sort",
        style: .plain,
        target: self,
        action: #selector(sortGenres)
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        data = MyTableViewDataSource(store: .shared)
        data.onChange = { [weak self] in
            self?.updateNavigationItems()
        }
        tableView.apply(data.makeSections(), animated: false)
        updateNavigationItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.apply(data.makeSections(), animated: false)
        updateNavigationItems()
    }
    
    @IBAction func edit(sender: AnyObject!) {
        isGenresEditing.toggle()
        self.tableView.setEditing(isGenresEditing, animated: true)
        updateNavigationItems()
    }

    @objc private func addGenre() {
        let alertController = UIAlertController(title: "Add Genre", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Genre name"
            textField.clearButtonMode = .whileEditing
            textField.addTarget(self, action: #selector(self.genreNameDidChange(_:)), for: .editingChanged)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard
                let self,
                let genreName = alertController?.textFields?.first?.text
            else {
                return
            }

            if self.data.addGenre(named: genreName) {
                self.tableView.apply(self.data.makeSections())
            } else {
                self.presentGenreValidationAlert()
            }
        }
        addAction.isEnabled = false
        self.addGenreAction = addAction

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true)
    }

    @objc private func sortGenres() {
        guard data.areGenresSorted == false else {
            return
        }

        data.sortGenres()
        tableView.apply(data.makeSections())
    }

    @objc private func genreNameDidChange(_ textField: UITextField) {
        let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        addGenreAction?.isEnabled = trimmedText.isEmpty == false
    }

    private func updateNavigationItems() {
        let systemItem: UIBarButtonItem.SystemItem = isGenresEditing ? .done : .edit
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(edit(sender:)))
        sortGenresBarButtonItem.isEnabled = data.areGenresSorted == false
        self.navigationItem.rightBarButtonItems = [addGenreBarButtonItem, sortGenresBarButtonItem]
    }

    private func presentGenreValidationAlert() {
        let alertController = UIAlertController(
            title: "Unable to Add Genre",
            message: "Enter a non-empty genre name that is not already in the list.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

}
