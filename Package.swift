// swift-tools-version:5.3
import PackageDescription

var package = Package(
    name: "ImGui",
    products: [
        .library(name: "ImGui", targets: ["ImGui"])
    ],
    targets: [
        .target(name: "ImGui", dependencies: ["CImGui"]),
        .target(name: "CImGui",
                path: "Sources/CImGui",
                cSettings: [.define("CIMGUI_DEFINE_ENUMS_AND_STRUCTS")],
                cxxSettings: [.define("CIMGUI_DEFINE_ENUMS_AND_STRUCTS")]),
        .target(name: "AutoWrapper",
                resources: [
                    .copy("Assets/definitions.json")
                ]),
        .testTarget(name: "ImGuiTests", dependencies: ["ImGui"])
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx11
)

package.products.append(.executable(name: "DemoMinimal", targets: ["DemoMinimal"]))
package.targets.append(.target(name: "DemoMinimal", dependencies: ["ImGui"], path: "Sources/Demos/Minimal"))

#if canImport(Metal) && os(macOS)
package.products.append(.executable(name: "DemoMetal-macOS", targets: ["DemoMetal"]))
package.targets.append(.target(name: "DemoMetal", dependencies: ["ImGui"], path: "Sources/Demos/Metal"))
#endif
