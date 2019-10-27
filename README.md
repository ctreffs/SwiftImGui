# Swift ImGui
[![Build Status](https://travis-ci.com/ctreffs/TODO.svg?branch=master)](https://travis-ci.com/ctreffs/TODO)
[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![swift version](https://img.shields.io/badge/swift-5.0+-brightgreen.svg)](https://swift.org/download)
[![platforms](https://img.shields.io/badge/platforms-%20macOS%20|%20iOS%20|%20tvOS%20|%20watchOS-brightgreen.svg)](#)
[![platforms](https://img.shields.io/badge/platforms-linux-brightgreen.svg)](#)


<img src="docs/swiftimgui.gif" height="300" align="middle"/>


This is a **lightweight**, **auto-generated** and **thin** Swift wrapper around the popular and excellent [**dear imgui**](https://github.com/ocornut/imgui) library.  
It provides a swiftly and typesafe API and is easily maintainable and updatable, since it relies heavily on auto-generation.

There is a working [demo example](Sources/Demos/Metal) provided as part of the library.




## Dependencies

Since SwiftImGui is merely a wrapper around **imgui** it obviously depends on it. 
It also makes use of the excellent c-api wrapper cimgui.
Here are some credits to the authros.

### imgui credits

##### From [ocornut/imgui/docs/README.md](https://github.com/ocornut/imgui/blob/master/docs/README.md):

<sub>(This library is available under a free and permissive license, but needs financial support to sustain its continued improvements. In addition to maintenance and stability there are many desirable features yet to be added. If your company is using dear imgui, please consider reaching out. If you are an individual using dear imgui, please consider supporting the project via Patreon or PayPal.)</sub>

Businesses: support continued development via invoiced technical support, maintenance, sponsoring contracts:
<br>&nbsp;&nbsp;_E-mail: contact @ dearimgui dot org_

Individuals/hobbyists: support continued maintenance and development via the monthly Patreon:
<br>&nbsp;&nbsp;[![Patreon](https://raw.githubusercontent.com/wiki/ocornut/imgui/web/patreon_02.png)](http://www.patreon.com/imgui)

Individuals/hobbyists: support continued maintenance and development via PayPal:
<br>&nbsp;&nbsp;[![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WGHNC6MBFLZ2S)

----

Dear ImGui is a **bloat-free graphical user interface library for C++**. It outputs optimized vertex buffers that you can render anytime in your 3D-pipeline enabled application. It is fast, portable, renderer agnostic and self-contained (no external dependencies).

Dear ImGui is designed to **enable fast iterations** and to **empower programmers** to create **content creation tools and visualization / debug tools** (as opposed to UI for the average end-user). It favors simplicity and productivity toward this goal, and lacks certain features normally found in more high-level libraries.

Dear ImGui is particularly suited to integration in games engine (for tooling), real-time 3D applications, fullscreen applications, embedded applications, or any applications on consoles platforms where operating system features are non-standard.


### cimgui credits

##### From [cimgui/cimgui/README.md](https://github.com/cimgui/cimgui/blob/master/README.md)

CImGui is a thin c-api wrapper programmatically generated for the excellent C++ immediate mode gui Dear ImGui. All imgui.h functions are programmatically wrapped. Generated files are: cimgui.cpp, cimgui.h for C compilation. Also for helping in bindings creation, definitions.lua with function definition information and structs_and_enums.lua. This library is intended as a intermediate layer to be able to use Dear ImGui from other languages that can interface with C (like D - see D-binding)


## Alternatives

* [mnmly/Swift-imgui](https://github.com/mnmly/Swift-imgui)
* [troughton/SwiftImGui](https://github.com/troughton/SwiftImGui)

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](tags). 

## ✍️ Authors

* [Christian Treffs](https://github.com/ctreffs)

See also the list of [contributors](https://github.com/ctreffs/TODO/blob/master/project/contributors) who participated in this project.

## 🔏 Licenses

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

* imgui licensed under [MIT License](https://github.com/ocornut/imgui/blob/master/LICENSE.txt)
* CImGui licensed under [MIT License](https://github.com/cimgui/cimgui/blob/master/LICENSE)

## 🙏 Acknowledgments

