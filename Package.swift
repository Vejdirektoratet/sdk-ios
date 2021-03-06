// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VejdirektoratetSDK",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v10),
        .watchOS(.v3),
        .tvOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "VejdirektoratetSDK",
            targets: ["VejdirektoratetSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-rc.3"),
        .package(url: "https://github.com/JanGorman/Hippolyte.git", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VejdirektoratetSDK",
            dependencies: ["Alamofire"]),
        .testTarget(
            name: "VejdirektoratetSDKTests",
            dependencies: ["VejdirektoratetSDK", "Hippolyte"]),
    ]
)
