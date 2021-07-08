imgui_src := 3rdparty/cimgui
c_imgui_src := Sources/CImGui
swift_imgui_src := Sources/ImGui
release_dir := .build/release
autowrapper_assets := Sources/AutoWrapper/Assets

.PHONY: lint
lint:
	swiftlint autocorrect --format
	swiftlint lint --quiet

.PHONY: setupEnv
setupEnv:
	brew install luajit

.PHONY: copyLibImGui
copyLibImGui:
	cp $(imgui_src)/cimgui.h $(c_imgui_src)/include
	cp $(imgui_src)/cimgui.cpp $(c_imgui_src)
	cp $(imgui_src)/imgui/*.h $(c_imgui_src)/imgui
	cp $(imgui_src)/imgui/*.cpp $(c_imgui_src)/imgui
	cp $(imgui_src)/generator/output/definitions.json $(autowrapper_assets)/definitions.json

.PHONY: generateCInterface
generateCInterface:
	cd $(imgui_src)/generator && luajit ./generator.lua gcc "internal" glfw glut metal sdl

.PHONY: buildCImGui
buildCImGui: generateCInterface copyLibImGui

.PHONY: buildAutoWrapper
buildAutoWrapper:
	swift build -c release --product AutoWrapper

.PHONY: buildRelease
buildRelease:
	swift build -c release -Xcxx -Wno-modules-import-nested-redundant -Xcxx -Wno-return-type-c-linkage

.PHONY: runCI
runCI:
	swift package reset
	swift build -c release -Xcxx -Wno-modules-import-nested-redundant -Xcxx -Wno-return-type-c-linkage -Xcc -Wno-modules-import-nested-redundant -Xcc -Wno-return-type-c-linkage
	swift test -Xcxx -Wno-modules-import-nested-redundant -Xcxx -Wno-return-type-c-linkage -Xcc -Wno-modules-import-nested-redundant -Xcc -Wno-return-type-c-linkage

.PHONY: wrapLibImGui
wrapLibImGui: buildAutoWrapper
	$(release_dir)/AutoWrapper $(imgui_src)/generator/output/definitions.json $(swift_imgui_src)/ImGui+Definitions.swift

.PHONY: testReadme
testReadme:
	markdown-link-check -p -v ./README.md
