//
//  ChangeListener.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 26/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

protocol ChangeNotifier {
    weak var changeListener: ChangeListener? { get set }
}

protocol ChangeListener: class {
    func notify(notifier: ChangeNotifier)
}
