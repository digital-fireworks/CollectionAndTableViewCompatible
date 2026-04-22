// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "CollectionAndTableViewCompatible",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CollectionAndTableViewCompatible",
            targets: ["CollectionAndTableViewCompatible"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CollectionAndTableViewCompatible",
            dependencies: []),
        .testTarget(
            name: "CollectionAndTableViewCompatibleTests",
            dependencies: ["CollectionAndTableViewCompatible"]),
    ]
)
