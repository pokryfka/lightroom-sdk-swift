// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "lightroom-sdk-swift",
    products: [
        .library(name: "LightroomSDK", targets: ["LightroomSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", .upToNextMajor(from: "1.2.1")),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.22.0")),
        .package(url: "https://github.com/fabianfett/pure-swift-json.git", .upToNextMinor(from: "0.5.0")),
    ],
    targets: [
        .target(
            name: "LightroomSDK",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "PureSwiftJSON", package: "pure-swift-json"),
            ]
        ),
        .testTarget(
            name: "LightroomSDKTests",
            dependencies: ["LightroomSDK"]
        ),
    ]
)
