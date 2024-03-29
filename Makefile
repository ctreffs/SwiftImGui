imgui_src := 3rdparty/cimgui
c_imgui_src := Sources/CImGui
swift_imgui_src := Sources/ImGui
release_dir := .build/release
autowrapper_assets := Sources/AutoWrapper/Assets

SWIFT_PACKAGE_VERSION := $(shell swift package tools-version)

# Lint fix and format code.
.PHONY: lint-fix
lint-fix:
	mint run swiftlint --fix --quiet
	mint run swiftformat --quiet --swiftversion ${SWIFT_PACKAGE_VERSION} .

.PHONY: setupEnv
setupEnv:
	brew install luajit

.PHONY: build-release
build-release:
	swift build -c release -Xcxx -Wno-modules-import-nested-redundant -Xcxx -Wno-return-type-c-linkage -Xcc -Wno-modules-import-nested-redundant -Xcc -Wno-return-type-c-linkage

.PHONY: test
test:
	swift test -Xcxx -Wno-modules-import-nested-redundant -Xcxx -Wno-return-type-c-linkage -Xcc -Wno-modules-import-nested-redundant -Xcc -Wno-return-type-c-linkage

.PHONY: generateCInterface
generateCInterface:
	cd $(imgui_src)/generator && luajit ./generator.lua gcc "internal" glfw glut metal sdl

.PHONY: copyLibImGui
copyLibImGui:
	cp $(imgui_src)/cimgui.h $(c_imgui_src)/include
	cp $(imgui_src)/cimgui.cpp $(c_imgui_src)
	cp $(imgui_src)/imgui/*.h $(c_imgui_src)/imgui
	cp $(imgui_src)/imgui/*.cpp $(c_imgui_src)/imgui
	cp $(imgui_src)/generator/output/definitions.json $(autowrapper_assets)/definitions.json

.PHONY: buildAutoWrapper
buildAutoWrapper:
	swift build -c release --product AutoWrapper

.PHONY: wrapLibImGui
wrapLibImGui: buildAutoWrapper
	$(release_dir)/AutoWrapper

.PHONY: applyFixIfDefsPatch
applyFixIfDefsPatch: 
	git apply patch_fix_ifdefs.diff
	
.PHONY: resetSubmodule
resetSubmodule:
	cd $(imgui_src) && git checkout -- .

.PHONY: update
update: generateCInterface copyLibImGui wrapLibImGui applyFixIfDefsPatch resetSubmodule

.PHONY: testReadme
testReadme:
	markdown-link-check -p -v ./README.md
