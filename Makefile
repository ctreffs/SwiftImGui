imgui_src := 3rdparty/cimgui
c_imgui_src := Sources/CImGui
swift_imgui_src := Sources/ImGui
release_dir := .build/release

lint:
	swiftlint autocorrect --format
	swiftlint lint --quiet

genLinuxTests:
	swift test --generate-linuxmain
	swiftlint autocorrect --format --path Tests/

test: genLinuxTests
	swift test

submodule:
	git submodule update --init --recursive

updateCLibImGui: submodule

copyLibImGui:
	cp $(imgui_src)/imgui/*.h $(c_imgui_src)/imgui
	cp $(imgui_src)/imgui/*.cpp $(c_imgui_src)/imgui
	cp $(imgui_src)/generator/output/cimgui.h $(c_imgui_src)/include
	cp $(imgui_src)/generator/output/cimgui.cpp $(c_imgui_src)

generateCInterface:
	cd $(imgui_src)/generator && luajit ./generator.lua gcc glfw opengl3 opengl2 sdl

buildCImGui: updateCLibImGui generateCInterface copyLibImGui

buildAutoWrapper:
	swift build -c release --product AutoWrapper

wrapLibImGui: buildAutoWrapper
	$(release_dir)/AutoWrapper $(imgui_src)/generator/output/definitions.json $(swift_imgui_src)/ImGui+Definitions.swift

clean:
	swift package reset
	rm -rdf .swiftpm/xcode
	rm -rdf .build/
	rm Package.resolved
	rm .DS_Store

cleanArtifacts:
	swift package clean

latest:
	swift package update

resolve:
	swift package resolve

genXcode:
	swift package generate-xcodeproj --enable-code-coverage --skip-extra-files 


genXcodeOpen: genXcode
	open *.xcodeproj

precommit: lint genLinuxTests

testReadme:
	markdown-link-check -p -v ./README.md
