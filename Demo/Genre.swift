//
//  Genre.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

struct Genre: Hashable, CustomStringConvertible {

    let name: String

    init(_ name: String) {
        self.name = name
    }

    static var allGenres: [Genre] {
        [
            Genre("Alternative"),
            Genre("Country"),
            Genre("Pop"),
            Genre("World"),
            Genre("Blues"),
            Genre("Singer Songwriter"),
            Genre("Metal"),
            Genre("Reggae"),
            Genre("Scene & Screen"),
            Genre("Rock"),
            Genre("Classic"),
            Genre("Jazz"),
            Genre("HipHop & Rap"),
            Genre("R&B and Soul"),
            Genre("Funk"),
            Genre("Dance"),
            Genre("Electronica"),
        ]
    }

    var description: String {
        name
    }
}
