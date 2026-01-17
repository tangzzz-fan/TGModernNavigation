// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NavigationFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NavigationFeature", targets: ["NavigationFeature"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../UIComponents"),
        .package(path: "../../../../../")
    ],
    targets: [
        .target(
            name: "NavigationFeature",
            dependencies: [
                "AppCore",
                "UIComponents",
                .product(name: "TGModernNavigation", package: "TGModernNavigation")
            ]
        ),
    ]
)
