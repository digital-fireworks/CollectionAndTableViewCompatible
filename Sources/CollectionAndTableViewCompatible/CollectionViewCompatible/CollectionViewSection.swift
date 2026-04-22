//
//  CollectionViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 31/01/2017.
//  Copyright © 2017 Fredrik Nannestad. All rights reserved.
//

import Foundation

@resultBuilder
public enum CollectionViewCellBuilder {

    public static func buildBlock(_ components: [CollectionViewCell]...) -> [CollectionViewCell] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: CollectionViewCell) -> [CollectionViewCell] {
        [expression]
    }

    public static func buildExpression(_ expression: [CollectionViewCell]) -> [CollectionViewCell] {
        expression
    }

    public static func buildOptional(_ component: [CollectionViewCell]?) -> [CollectionViewCell] {
        component ?? []
    }

    public static func buildEither(first component: [CollectionViewCell]) -> [CollectionViewCell] {
        component
    }

    public static func buildEither(second component: [CollectionViewCell]) -> [CollectionViewCell] {
        component
    }

    public static func buildArray(_ components: [[CollectionViewCell]]) -> [CollectionViewCell] {
        components.flatMap { $0 }
    }
}

@resultBuilder
public enum CollectionViewCellSectionBuilder {

    public static func buildBlock(_ components: [CollectionViewCellSection]...) -> [CollectionViewCellSection] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: CollectionViewCellSection) -> [CollectionViewCellSection] {
        [expression]
    }

    public static func buildExpression(_ expression: [CollectionViewCellSection]) -> [CollectionViewCellSection] {
        expression
    }

    public static func buildOptional(_ component: [CollectionViewCellSection]?) -> [CollectionViewCellSection] {
        component ?? []
    }

    public static func buildEither(first component: [CollectionViewCellSection]) -> [CollectionViewCellSection] {
        component
    }

    public static func buildEither(second component: [CollectionViewCellSection]) -> [CollectionViewCellSection] {
        component
    }

    public static func buildArray(_ components: [[CollectionViewCellSection]]) -> [CollectionViewCellSection] {
        components.flatMap { $0 }
    }
}

@MainActor
public struct CollectionViewCellSection {

    public let id: TableIdentifier
    public var cells: [CollectionViewCell]

    public init<ID: Hashable>(id: ID, cells: [CollectionViewCell]) {
        self.id = TableIdentifier(id)
        self.cells = cells
    }

    public init<ID: Hashable>(id: ID, @CollectionViewCellBuilder cells: () -> [CollectionViewCell]) {
        self.init(id: id, cells: cells())
    }
}

@MainActor
open class CollectionViewSection: NSObject {
    
    open var sortOrder: Int
    open var items: [CollectionViewCompatible]
    
    public init(sortOrder: Int, items: [CollectionViewCompatible]) {
        self.sortOrder = sortOrder
        self.items = items
    }
}

@MainActor
open class CollectionViewItemSection: NSObject {

    open var sortOrder: Int
    open var items: [CollectionViewItem]

    public init(sortOrder: Int, items: [CollectionViewItem]) {
        self.sortOrder = sortOrder
        self.items = items
    }
}
