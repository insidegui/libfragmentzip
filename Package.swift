// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "FragmentZip",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "FragmentZip", targets: ["FragmentZip"]),
    ],
    targets: [
        .target(
            name: "CFragmentZip",
            path: "Sources/CFragmentZip",
            sources: ["libfragmentzip.c"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
            ]
        ),
        .target(
            name: "FragmentZip",
            dependencies: [
                .target(name: "CFragmentZip")
            ],
            path: "Sources/FragmentZip"
        )
    ]
)
