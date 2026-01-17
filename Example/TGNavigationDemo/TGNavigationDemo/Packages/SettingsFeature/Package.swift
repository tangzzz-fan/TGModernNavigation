// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SettingsFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../UIComponents"),
        .package(path: "../../../../../")
    ],
    targets: [
        .target(
            name: "SettingsFeature",
            dependencies: [
                "AppCore",
                "UIComponents",
                .product(name: "TGModernNavigation", package: "TGModernNavigation")
            ]
        ),
    ]
)
