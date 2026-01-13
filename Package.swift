// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WorkLogger",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "WorkLogger", targets: ["WorkLogger"])
    ],
    targets: [
        .executableTarget(
            name: "WorkLogger",
            path: ".",
            exclude: ["Package.swift"],
            sources: [
                "WorkLoggerApp.swift",
                "AppDelegate.swift",
                "MainView.swift",
                "CalendarManager.swift",
                "Models.swift"
            ]
        )
    ]
)
