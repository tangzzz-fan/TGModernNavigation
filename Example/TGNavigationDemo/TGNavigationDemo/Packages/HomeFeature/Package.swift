// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HomeFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../UIComponents"),
        .package(path: "../../../../../")
    ],
    targets: [
        .target(
            name: "HomeFeature",
            dependencies: [
                "AppCore",
                "UIComponents",
                .product(name: "TGModernNavigation", package: "TGModernNavigation")
            ]
        ),
    ]
)
