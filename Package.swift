// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "EasyBackgroundRefresh",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "EasyBackgroundRefresh", targets: ["EasyBackgroundRefresh"]),
    ],
    targets: [
        .target(
            name: "EasyBackgroundRefresh",
            dependencies: [],
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
