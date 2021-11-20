// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaDownloadManager",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "MediaDownloadManager",
            targets: ["MediaDownloadManager"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "MediaDownloadManager",
            dependencies: []),
        .testTarget(
            name: "MediaDownloadManagerTests",
            dependencies: ["MediaDownloadManager"]),
    ]
)
