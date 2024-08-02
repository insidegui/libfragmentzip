// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "CFragmentZip",
    products: [
        .library(name: "CFragmentZip", targets: ["CFragmentZip"]),
    ],
    targets: [
        .target(
            name: "CFragmentZip",
            path: ".",
            sources: ["Sources/libfragmentzip.c"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources"),
                .headerSearchPath(".")
            ]
        ),
    ]
)