imgui_src := 3rdparty/cimgui
c_imgui_src := Sources/CImGUI
swift_imgui_src := Sources/ImGUI
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
	git submodule init
	git submodule update --recursive

updateCLibImGUI:
	git submodule init $(imgui_src)
	git submodule update --recursive $(imgui_src)

copyLibImGui:
	cp $(imgui_src)/imgui/*.h $(c_imgui2_src)/imgui
	cp $(imgui_src)/imgui/*.cpp $(c_imgui2_src)/imgui
	cp $(imgui_src)/generator/output/cimgui.h $(c_imgui2_src)/include
	#cp $(imgui_src)/generator/output/cimgui_impl.h $(c_imgui2_src)
	cp $(imgui_src)/generator/output/cimgui.cpp $(c_imgui2_src)

generateCInterface:
	cd $(imgui_src)/generator && luajit ./generator.lua gcc glfw opengl3 opengl2 sdl

buildAutoWrapper:
	swift build -c release --product AutoWrapper

wrapLibImGui: buildAutoWrapper
	$(release_dir)/AutoWrapper $(imgui_src)/generator/output/definitions.json $(swift_imgui_src)/ImGUI+Definitions.swift

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


	#$(MAKE) -C $(imgui_src) clean
	#$(MAKE) -C $(imgui_src)
	#cd $(imgui_src) && 
	#	ar -cvq libcimgui.a cimgui.o ./imgui/imgui.o ./imgui/imgui_draw.o ./imgui/imgui_demo.o ./imgui/imgui_widgets.o && 
	#	mv -f libcimgui.a $(c_imgui_src)/lib &&
	#$(MAKE) -C $(imgui_src) clean