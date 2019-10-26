// swift-tools-version:5.0
import PackageDescription

var package = Package(
    name: "ImGui",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "ImGui", targets: ["ImGui"]),
        .library(name: "CImGui", targets: ["CImGui"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "ImGui", dependencies: ["CImGui"]),
        .target(name: "CImGui", path: "Sources/CImGui", cxxSettings: [.define("CIMGUI_DEFINE_ENUMS_AND_STRUCTS")]),
        .target(name: "AutoWrapper"),
        .testTarget(name: "ImGuiTests", dependencies: ["ImGui"])
    ],
    cxxLanguageStandard: .cxx11
)

#if canImport(Metal) && os(macOS)
let metalDemo: (Product, Target) =
    (.executable(name: "DemoMetal-macOS", targets: ["DemoMetal"]),
     .target(name: "DemoMetal", dependencies: ["ImGui"], path: "Sources/Demos/Metal"))
package.products.append(metalDemo.0)
package.targets.append(metalDemo.1)
#endif
