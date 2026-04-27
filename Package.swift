// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HabitifyBar",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "HabitifyBar",
            path: "Sources",
            exclude: ["Info.plist", "HabitifyBar.entitlements"],
            linkerSettings: [
                .linkedFramework("Security"),
                .linkedFramework("ServiceManagement")
            ]
        )
    ]
)
