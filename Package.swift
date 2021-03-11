// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Sodium",
    products: [
        .library(
            name: "Clibsodium",
            targets: ["Clibsodium"]),
        .library(
            name: "Sodium",
            type: .dynamic,
            targets: ["Sodium"]),
    ],
    targets: [
        .binaryTarget(
            name: "Clibsodium",
            path: "Clibsodium.xcframework"),
        .target(
            name: "Sodium",
            dependencies: ["Clibsodium"],
            path: "Sodium",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "SodiumTests",
            dependencies: ["Sodium"],
            exclude: ["Info.plist"]),
    ]
)
