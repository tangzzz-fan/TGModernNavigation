// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AuthFeature", targets: ["AuthFeature"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../../../../../")
    ],
    targets: [
        .target(
            name: "AuthFeature",
            dependencies: [
                "AppCore",
                .product(name: "TGModernNavigation", package: "TGModernNavigation")
            ]
        ),
    ]
)
