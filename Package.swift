// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataHustle",
    products: [
        .executable(name: "DataHustle", targets: ["DataHustle"]),
    ],
    dependencies: [
        .package(url: "https://github.com/piotte13/SwiftRoaring",  from: "1.0.4")
    ],
    targets: [
        .target(
            name: "DataHustle",
            dependencies: ["SwiftRoaring"]),
        .testTarget(
            name: "DataHustleTests",
            dependencies: ["DataHustle"]),
    ]
)
