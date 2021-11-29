// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemodelAR",
    platforms: [.iOS("13.4")],
    products: [
        .library(
            name: "RemodelAR",
            targets: ["RemodelAR"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "RemodelAR",
            path: "./framework/RemodelAR.xcframework"
        )
    ]
)
