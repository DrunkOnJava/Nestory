// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NestoryGuards",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "NestoryGuards",
            targets: ["NestoryGuards"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.0.0"),
    ],
    targets: [
        .target(
            name: "NestoryGuards",
            path: "Sources/NestoryGuards"
        ),
        .testTarget(
            name: "ArchitectureTests",
            dependencies: [
                "NestoryGuards",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "Tests/ArchitectureTests"
        ),
    ]
)
