//
//  TableViewCompatible.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 21/10/2016.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import Foundation
import UIKit

/**
 Let your model object conform to this protocol to make it compatible with a `UITableView`
 */
protocol TableViewCompatible {
    
    var reuseIdentifier: String { get }
    
    /// Call this from your `UITableViewDataSource` and return a fully configured `UITableViewCell`. If your cells conforms to the `Configurable` protocol, you can call `configureWithModel(_: T)` with `self` as parameter in your implementation.
    /// parameter tableView: a table view requesting the cell.
    /// parameter indexPath: an index path locating the row in the table view.
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    
}
