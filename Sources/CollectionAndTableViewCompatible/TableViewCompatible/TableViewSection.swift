//
//  TableViewSection.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 24/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import Foundation

@resultBuilder
public enum TableRowBuilder {

    public static func buildBlock(_ components: [TableRow]...) -> [TableRow] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: TableRow) -> [TableRow] {
        [expression]
    }

    public static func buildExpression(_ expression: [TableRow]) -> [TableRow] {
        expression
    }

    public static func buildOptional(_ component: [TableRow]?) -> [TableRow] {
        component ?? []
    }

    public static func buildEither(first component: [TableRow]) -> [TableRow] {
        component
    }

    public static func buildEither(second component: [TableRow]) -> [TableRow] {
        component
    }

    public static func buildArray(_ components: [[TableRow]]) -> [TableRow] {
        components.flatMap { $0 }
    }
}

@resultBuilder
public enum TableSectionBuilder {

    public static func buildBlock(_ components: [TableSection]...) -> [TableSection] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: TableSection) -> [TableSection] {
        [expression]
    }

    public static func buildExpression(_ expression: [TableSection]) -> [TableSection] {
        expression
    }

    public static func buildOptional(_ component: [TableSection]?) -> [TableSection] {
        component ?? []
    }

    public static func buildEither(first component: [TableSection]) -> [TableSection] {
        component
    }

    public static func buildEither(second component: [TableSection]) -> [TableSection] {
        component
    }

    public static func buildArray(_ components: [[TableSection]]) -> [TableSection] {
        components.flatMap { $0 }
    }
}

@MainActor
public struct TableSection {

    public let id: TableIdentifier
    public var headerTitle: String?
    public var footerTitle: String?
    public var rows: [TableRow]

    public init<ID: Hashable>(
        id: ID,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        rows: [TableRow]
    ) {
        self.id = TableIdentifier(id)
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self.rows = rows
    }

    public init<ID: Hashable>(
        _ headerTitle: String? = nil,
        id: ID,
        footerTitle: String? = nil,
        @TableRowBuilder rows: () -> [TableRow]
    ) {
        self.init(id: id, headerTitle: headerTitle, footerTitle: footerTitle, rows: rows())
    }
}

@MainActor
public extension TableSection {

    func sortedRows(by areInIncreasingOrder: (TableRow, TableRow) -> Bool) -> Self {
        var copy = self
        copy.rows = rows
            .enumerated()
            .sorted { lhs, rhs in
                if areInIncreasingOrder(lhs.element, rhs.element) {
                    return true
                }

                if areInIncreasingOrder(rhs.element, lhs.element) {
                    return false
                }

                return lhs.offset < rhs.offset
            }
            .map(\.element)
        return copy
    }

    func sortedRows<Model>(
        as type: Model.Type = Model.self,
        by areInIncreasingOrder: (Model, Model) -> Bool
    ) -> Self {
        sortedRows { lhs, rhs in
            switch (lhs.model(as: type), rhs.model(as: type)) {
            case let (lhsModel?, rhsModel?):
                return areInIncreasingOrder(lhsModel, rhsModel)
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return false
            }
        }
    }
}

@MainActor
open class TableViewSection {

    open var sortOrder: Int
    open var items: [TableViewCompatible]
    open var headerTitle: String?
    open var footerTitle: String?

    public init(sortOrder: Int, items: [TableViewCompatible], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.sortOrder = sortOrder
        self.items = items
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }

}

@MainActor
open class TableViewRowSection {

    open var sortOrder: Int
    open var items: [TableViewRow]
    open var headerTitle: String?
    open var footerTitle: String?

    public init(sortOrder: Int, items: [TableViewRow], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.sortOrder = sortOrder
        self.items = items
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }
}
