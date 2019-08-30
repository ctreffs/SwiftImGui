// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImGUI",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "CImGUI",
                 type: .static,
                 targets: ["CImGUI"]),
        .library(
            name: "ImGUI",
            type: .static,
            targets: ["ImGUI"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "CImGUI",
                exclude: ["cimgui/"],
                cSettings: [
                    .unsafeFlags(["-I", "Sources/CImGUI/include"])
            ],
                linkerSettings: [
                    .unsafeFlags(["-L", "Sources/CImGUI/lib"]),
                    .linkedLibrary("cimgui")
            ]
        ),
        .target(
            name: "ImGUI",
            dependencies: ["CImGUI"]),
        .testTarget(
            name: "ImGUITests",
            dependencies: ["ImGUI"])
    ]
)
