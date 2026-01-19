// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WorkLogger",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "WorkLoggerLib", targets: ["WorkLoggerLib"]),
        .executable(name: "WorkLogger", targets: ["WorkLogger"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .target(
            name: "WorkLoggerLib",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
        .executableTarget(
            name: "WorkLogger",
            dependencies: ["WorkLoggerLib"]
        ),
        .testTarget(
            name: "WorkLoggerTests",
            dependencies: ["WorkLoggerLib"]
        )
    ]
)
