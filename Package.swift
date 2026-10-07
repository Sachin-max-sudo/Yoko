// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "Yoko", platforms: [.macOS(.v14)], products: [
    .executable(name: "Yoko", targets: ["YokoApp"]),
    .library(name: "YokoCore", targets: ["YokoCore"])
], targets: [
    .systemLibrary(name: "CSQLite"),
    .target(name: "YokoCore", dependencies: ["CSQLite"]),
    .executableTarget(name: "YokoApp", dependencies: ["YokoCore"]),
    .testTarget(name: "YokoCoreTests", dependencies: ["YokoCore"])
], swiftLanguageModes: [.v5])
