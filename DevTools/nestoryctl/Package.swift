// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "nestoryctl",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "nestoryctl",
            targets: ["NestoryCtl"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "NestoryCtl",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
        ),
    ],
)
