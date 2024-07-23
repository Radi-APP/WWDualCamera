// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWDualCamera",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "WWDualCamera", targets: ["WWDualCamera"]),
    ],
    targets: [
        .target(name: "WWDualCamera")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
