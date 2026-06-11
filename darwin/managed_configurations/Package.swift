// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "managed_configurations",
    platforms: [
        .iOS("11.0"),
        .macOS("10.14"),
    ],
    products: [
        .library(name: "managed-configurations", targets: ["managed_configurations"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "managed_configurations",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
