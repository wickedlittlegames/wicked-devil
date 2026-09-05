// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WickedDevilCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "WickedDevilCore", targets: ["WickedDevilCore"])
    ],
    targets: [
        .target(name: "WickedDevilCore"),
        .testTarget(name: "WickedDevilCoreTests", dependencies: ["WickedDevilCore"])
    ]
)
