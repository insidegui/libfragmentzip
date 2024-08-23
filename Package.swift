// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "FragmentZip",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "FragmentZip", targets: ["FragmentZip"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "CFragmentZip",
            path: "Sources/CFragmentZip",
            sources: ["libfragmentzip.c"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
            ],
            linkerSettings: [
                .linkedLibrary("curl")
            ]
        ),
        .target(
            name: "FragmentZip",
            dependencies: [
                .target(name: "CFragmentZip")
            ],
            path: "Sources/FragmentZip"
        ),
        .executableTarget(
            name: "fzip",
            dependencies: [
                .target(name: "FragmentZip"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
