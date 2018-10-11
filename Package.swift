// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataHustle",
    products: [
        .library(name: "Math", targets: ["Math"]),
        .executable(name: "DataHustle", targets: ["DataHustle"])
    ],
    dependencies: [
        .package(url: "https://github.com/piotte13/SwiftRoaring",  from: "1.0.4")
    ],
    targets: [
        .target(
            name: "Math",
            dependencies: []),
        .target(
            name: "DataHustle",
            dependencies: ["SwiftRoaring", "Math"]),
        .testTarget(
            name: "DataHustleTests",
            dependencies: ["DataHustle"]),
    ]
)
