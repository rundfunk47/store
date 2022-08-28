// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Store",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v7)],
    products: [
        .library(
            name: "Store",
            targets: ["Store"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Store",
            path: "Sources"
        )
    ]
)
