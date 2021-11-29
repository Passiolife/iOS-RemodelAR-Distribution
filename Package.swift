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
            url: "https://github.com/Passiolife/iOS-AR-Remodel-Module/releases/download/1.0.1/RemodelAR.xcframework.zip",
            checksum: "97f9705740dada4d78e786baedec3c68bdde24eda0fb6cadee2e29869da51d19"
        )
    ]
)
