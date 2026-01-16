// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TGModernNavigation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "TGModernNavigation",
            targets: ["TGModernNavigation"]
        ),
    ],
    targets: [
        .target(
            name: "TGModernNavigation"
        ),
        .testTarget(
            name: "TGModernNavigationTests",
            dependencies: ["TGModernNavigation"]
        ),
    ]
)
