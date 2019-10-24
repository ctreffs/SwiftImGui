// swift-tools-version:5.0
import PackageDescription

var package = Package(
    name: "ImGUI",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "ImGUI", targets: ["ImGUI"]),
        .library(name: "CImGUI", targets: ["CImGUI"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "ImGUI", dependencies: ["CImGUI"]),
        .target(name: "CImGUI", cxxSettings: [.define("CIMGUI_DEFINE_ENUMS_AND_STRUCTS")]),
        .target(name: "Generator"),
        .testTarget(name: "ImGUITests", dependencies: ["ImGUI"])
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
