# Swift ImGui

[![macOS](https://github.com/ctreffs/SwiftImGui/actions/workflows/ci-macos.yml/badge.svg)](https://github.com/ctreffs/SwiftImGui/actions/workflows/ci-macos.yml)
[![Linux](https://github.com/ctreffs/SwiftImGui/actions/workflows/ci-linux.yml/badge.svg)](https://github.com/ctreffs/SwiftImGui/actions/workflows/ci-linux.yml)
[![Windows](https://github.com/ctreffs/SwiftImGui/actions/workflows/ci-windows.yml/badge.svg)](https://github.com/ctreffs/SwiftImGui/actions/workflows/ci-windows.yml)
[![platform-compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fctreffs%2FSwiftImGui%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ctreffs/SwiftImGui)   
[![swift-version-compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fctreffs%2FSwiftImGui%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ctreffs/SwiftImGui)
[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)  

<p align="center">
	<img src="docs/swiftimgui.gif" width="100%" alt="swiftimgui-gif"/>
</p>   

This is a **lightweight**, **auto-generated** and **thin** Swift wrapper around the popular and excellent [**dear imgui**](https://github.com/ocornut/imgui) library.  

It provides a **swifty** and especially **typesafe** API. It is easily maintainable and updatable, as well, since it relies heavily on automated code generation.

There are working [demo examples](Sources/Demos/), too, provided as part of the library.

Currently it is based on **v1.86** of ImGui.

## 🚀 Getting Started

These instructions will get your copy of the project up and running on your local machine and provide a code example.

### 📋 Prerequisites

* [Swift Package Manager (SPM)](https://github.com/apple/swift-package-manager)
* [Swiftlint](https://github.com/realm/SwiftLint) for linting - (optional)

### 💻 Installing

Swift ImGui is available for all platforms that support [Swift 5.3](https://swift.org/) and higher and the [Swift Package Manager (SPM)](https://github.com/apple/swift-package-manager).

Extend the following lines in your `Package.swift` file or use it to create a new project.

```swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "YourPackageName",
    dependencies: [
        .package(url: "https://github.com/ctreffs/SwiftImGui.git", from: "1.86.0")
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: ["ImGui"])
    ]
)

```


## 📝 Code Example

### Minimal

A minimal example is located at [Sources/Demos/Minimal/main.swift](Sources/Demos/Minimal/main.swift).   

This is an excerpt:

```swift
import ImGui

IMGUI_CHECKVERSION()
let ctx = ImGuiCreateContext(nil)
let io = ImGuiGetIO()!

/// Build font atlas
var pixels: UnsafeMutablePointer<UInt8>?
var width: Int32 = 0
var height: Int32 = 0
var bytesPerPixel: Int32 = 0
ImFontAtlas_GetTexDataAsRGBA32(io.pointee.Fonts, &pixels, &width, &height, &bytesPerPixel)

for n in 0..<20 {
    io.pointee.DisplaySize = ImVec2(x: 1920, y: 1080)
    io.pointee.DeltaTime = 1.0 / 60.0
    ImGuiNewFrame()
    var f: Float = 0.0
    ImGuiTextV("Hello, world!")
    ImGuiSliderFloat("float", &f, 0.0, 1.0, nil, 1)
    ImGuiTextV("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / io.pointee.Framerate, io.pointee.Framerate)
    ImGuiShowDemoWindow(nil)
    ImGuiRender()
}

ImGuiDestroyContext(ctx)
```

### Metal + OSX

This is another demo displaying ImGui demo window at [Sources/Demos/Metal](Sources/Demos/Metal).

<p align="center">
    <img src="docs/imgui_demo.png" width="70%" alt="imgui_demo"/>
</p> 

It provides two backend files ([imgui_impl_metal.swift](Sources/Demos/Metal/imgui_impl_metal.swift), [imgui_impl_osx.swift](Sources/Demos/Metal/imgui_impl_metal.swift)). Feel free to include more backends for GLFW, SDL2, etc.

## 🆕 Update SwiftImGui

SwiftImGui uses a mutli-stage process to update to the latest [cimgui](https://github.com/cimgui/cimgui) and [imgui](https://github.com/ocornut/imgui) versions.

See [HOWTO.md](docs/HOWTO.md) for steps about how to contribute.

## 💁 Help Needed

This project needs a lot of love.
If you are interested in contributing please feel free to do so!

Things that need to be done among others are:

- [ ] Extend the AutoWrapper to wrap more cimgui functions
    - Currently there are **112** 'invalid' functions that will not be wrapped and **974** will be wrapped properly.
- [ ] Some functions are not available via the C interface - see `Sources/AutoWrapper/Exceptions.swift`
- [ ] Find a solution for manual adjustments in cimgui generator template
- [ ] Write some more tests

## 🏷️ Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases](https://github.com/ctreffs/SwiftImGui/releases) in this repository.

## ✍️ Authors

* [Christian Treffs](https://github.com/ctreffs)

See also the list of [contributors](https://github.com/ctreffs/SwiftImGui/graphs/contributors) who participated in this project.

## 🔏 Licenses

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

* imgui licensed under [MIT License](https://github.com/ocornut/imgui/blob/master/LICENSE.txt)
* CImGui licensed under [MIT License](https://github.com/cimgui/cimgui/blob/master/LICENSE)

## 🙏 Original Code

SwiftImGui is merely a wrapper around [**imgui**](https://github.com/ocornut/imgui). It also makes use of the excellent C-API wrapper [**cimgui**](https://github.com/cimgui/cimgui).

Support them if you can!

### imgui

##### From [ocornut/imgui/docs/README.md](https://github.com/ocornut/imgui/blob/master/docs/README.md):

> Dear ImGui is a **bloat-free graphical user interface library for C++**. It outputs optimized vertex buffers that you can render anytime in your 3D-pipeline enabled application. It is fast, portable, renderer agnostic and self-contained (no external dependencies).
> 
> Dear ImGui is designed to **enable fast iterations** and to **empower programmers** to create **content creation tools and visualization / debug tools** (as opposed to UI for the average end-user). It favors simplicity and productivity toward this goal, and lacks certain features normally found in more high-level libraries.
> 
> Dear ImGui is particularly suited to integration in games engine (for tooling), real-time 3D applications, fullscreen applications, embedded applications, or any applications on consoles platforms where operating system features are non-standard.

<sub>(This library is available under a free and permissive license, but needs financial support to sustain its continued improvements. In addition to maintenance and stability there are many desirable features yet to be added. If your company is using dear imgui, please consider reaching out. If you are an individual using dear imgui, please consider supporting the project via Patreon or PayPal.)</sub>

- **Businesses:** support continued development via invoiced technical support, maintenance, sponsoring contracts:
<br>&nbsp;&nbsp;_E-mail: contact @ dearimgui dot org_
- **Individuals/hobbyists:** support continued maintenance and development via the monthly Patreon:
<br>&nbsp;&nbsp;[![Patreon](https://raw.githubusercontent.com/wiki/ocornut/imgui/web/patreon_02.png)](http://www.patreon.com/imgui)
- **Individuals/hobbyists:** support continued maintenance and development via PayPal:
<br>&nbsp;&nbsp;[![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WGHNC6MBFLZ2S)

----

### cimgui

##### From [cimgui/cimgui/README.md](https://github.com/cimgui/cimgui/blob/master/README.md)

> CImGui is a thin C-API wrapper programmatically generated for the excellent C++ immediate mode GUI Dear ImGui. All imgui.h functions are programmatically wrapped. Generated files are: cimgui.cpp, cimgui.h for C compilation. Also for helping in bindings creation, definitions.lua with function definition information and structs_and_enums.lua. This library is intended as a intermediate layer to be able to use Dear ImGui from other languages that can interface with C (like D - see D-binding)


## ☮️ Alternatives

* [mnmly/Swift-imgui](https://github.com/mnmly/Swift-imgui)
* [troughton/SwiftImGui](https://github.com/troughton/SwiftImGui)
