// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "STAboutKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "STAboutKit",
            targets: ["STAboutKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: Version(5, 0, 0)))
    ],
    targets: [
        .target(
            name: "STAboutKit",
            dependencies: [
                "SnapKit"
            ],
            path: "Sources/STAboutKit",
            resources: [
                .process("Localizable")
            ]
        ),
        .testTarget(
            name: "STAboutKitTests",
            dependencies: ["STAboutKit"],
            path: "Tests/STAboutKitTests"
        )
    ]
)
