// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppCore", targets: ["AppCore"]),
    ],
    dependencies: [
        .package(path: "../../../../../")
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                .product(name: "TGModernNavigation", package: "TGModernNavigation")
            ]
        ),
    ]
)
