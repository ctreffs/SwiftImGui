// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var package = Package(
    name: "ImGUI",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ImGUI",
            type: .static,
            targets: ["ImGUI"]),
        .library(name: "CImGUI",
                 targets: ["CImGUI"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ImGUI",
            dependencies: ["CImGUI"]),
        .testTarget(
            name: "ImGUITests",
            dependencies: ["ImGUI"]),
        .target(name: "CImGUI",
                path: "Sources/CImGUI2",
                cSettings: [
                    //.define("CIMGUI_DEFINE_ENUMS_AND_STRUCTS"),
                    .define("CIMGUI_SKIP_DEFINE_ENUMS_AND_STRUCTS"),
                    .define("IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1"),
                    .define("CIMGUI_NO_EXPORT")],
                cxxSettings: [
                    //.define("CIMGUI_DEFINE_ENUMS_AND_STRUCTS"),
                    .define("CIMGUI_SKIP_DEFINE_ENUMS_AND_STRUCTS"),
                    .define("IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1"),
                    .define("CIMGUI_NO_EXPORT")]),
        .target(name: "Generator")
    ],
    cxxLanguageStandard: .cxx11
)

#if os(macOS)
let macOSDemo: (Product, Target) =
    (.executable(name: "ImGUI-demo", targets: ["ImGUI-demo"]),
     .target(name: "ImGUI-demo", dependencies: ["ImGUI"]))
package.products.append(macOSDemo.0)
package.targets.append(macOSDemo.1)
#endif
