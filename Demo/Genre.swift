//
//  Genre.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 25/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

enum Genre {
    case Alternative
    case Country
    case Pop
    case World
    case Blues
    case SingerSongwriter
    case Metal
    case Reggae
    case SceneScreen
    case Rock
    case Classic
    case Jazz
    case HipHopRap
    case RnBSoul
    case Funk
    case Dance
    case Electronica
}

extension Genre: CustomStringConvertible {
    static var allGenres: [Genre] {
        return [
            Alternative,
            Country,
            Pop,
            World,
            Blues,
            SingerSongwriter,
            Metal,
            Reggae,
            SceneScreen,
            Rock,
            Classic,
            Jazz,
            HipHopRap,
            RnBSoul,
            Funk,
            Dance,
            Electronica
        ]
    }
    
    var description: String {
        switch self {
        case .Alternative:
            return "Alternative"
        case .Country:
            return "Country"
        case .Pop:
            return "Pop"
        case .World:
            return "World"
        case .Blues:
            return "Blues"
        case .SingerSongwriter:
            return "Singer Songwriter"
        case .Metal:
            return "Metal"
        case .Reggae:
            return "Reggae"
        case .SceneScreen:
            return "Scene & Screen"
        case .Rock:
            return "Rock"
        case .Classic:
            return "Classic"
        case .Jazz:
            return "Jazz"
        case .HipHopRap:
            return "HipHop & Rap"
        case .RnBSoul:
            return "R&B and Soul"
        case .Funk:
            return "Funk"
        case .Dance:
            return "Dance"
        case .Electronica:
            return "Electronica"
        }
    }
}
