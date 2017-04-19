//
//  ChangeListener.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 26/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

public protocol ChangeNotifier {
    weak var changeListener: ChangeListener? { get set }
}

public protocol ChangeListener: class {
    func notify(notifier: ChangeNotifier)
}
