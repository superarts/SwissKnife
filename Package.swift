// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwissKnife",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwissKnife",
            targets: ["SwissKnifeCore"]
        ),
        .library(
            name: "SwissKnifeLogger",
            targets: ["SwissKnifeLogger"]
        ),
        .library(
            name: "SwissKnifeFoundation",
            targets: ["SwissKnifeCoreFoundation"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            url: "https://github.com/Quick/Quick.git", 
            .upToNextMinor(from: "3.0.0")
        ),
        .package(
            url: "https://github.com/Quick/Nimble.git", 
            .upToNextMinor(from: "9.0.0")
        ),
        /*
        .package(
            url: "https://github.com/drmohundro/SWXMLHash.git",
            .upToNextMinor(from: "6.0.0")
        ),
        */
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwissKnifeCore",
            dependencies: [
                //"SWXMLHash",
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "SwissKnifeLogger",
            dependencies: [
                "SwissKnifeCore",
            ],
            path: "Sources/Logger"
        ),
        .target(
            name: "SwissKnifeCoreFoundation",
            dependencies: [
                "SwissKnifeCore",
            ],
            path: "Sources/CoreFoundation"
        ),
        .testTarget(
            name: "SwissKnifeTests",
            dependencies: [
                "SwissKnifeCore",
                "SwissKnifeLogger",
                "SwissKnifeCoreFoundation",
                "Quick",
                "Nimble"
            ],
            path: "Tests"
        ),
    ]
)