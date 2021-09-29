// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCVDetector",
    dependencies: [],
    targets: [
        .target(
            name: "XCVDetectorLib",
            dependencies: []),
        .target(
            name: "xcvdetector",
            dependencies: ["XCVDetectorLib"]),
        .testTarget(
            name: "XCVDetectorTests",
            dependencies: ["XCVDetectorLib"]),
    ]
)
