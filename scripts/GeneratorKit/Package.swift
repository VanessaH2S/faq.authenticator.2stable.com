// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GeneratorKit",
    products: [
        .executable(name: "GeneratorKit", targets: ["GeneratorKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", .branch("main")),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "GeneratorKit",
            dependencies: [
                "Files",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Markdown", package: "swift-markdown"),
                "Regex",
                "Yams"
            ]
        )
    ]
)
