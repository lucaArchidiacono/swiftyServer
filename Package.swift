// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftyServer",
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-nio",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/johnsundell/ink.git",
            from: "0.1.0"
       )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "swiftyServer",
            dependencies: [
                .product(
                    name: "NIO",
                    package: "swift-nio"
                ),
                .product(
                    name: "NIOHTTP1",
                    package: "swift-nio"
                ),
                .product(
                    name: "Ink",
                    package: "ink"
                )
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
