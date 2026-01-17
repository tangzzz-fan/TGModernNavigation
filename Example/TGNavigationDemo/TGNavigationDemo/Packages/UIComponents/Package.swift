// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "UIComponents", targets: ["UIComponents"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AuthFeature"),
        .package(path: "../../../../../")
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                "AppCore",
                "AuthFeature",
                .product(name: "TGModernNavigation", package: "TGModernNavigation")
            ]
        ),
    ]
)
