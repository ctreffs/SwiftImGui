nicegraf_src := "3rdparty/nicegraf"
nicegraf_build := "3rdparty/nicegraf-build"
c_nicegraf_src := "Sources/CNicegraf"

cimgui_src := "Sources/CImGUI/cimgui/"

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

buildCImGUIStaticLib:
	$(MAKE) -C $(cimgui_src) clean
	$(MAKE) -C $(cimgui_src)
	cd $(cimgui_src) && 
		ar -cvq libcimgui.a cimgui.o ./imgui/imgui.o ./imgui/imgui_draw.o ./imgui/imgui_demo.o ./imgui/imgui_widgets.o && 
		mv -f libcimgui.a ../lib/
	$(MAKE) -C $(cimgui_src) clean


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

genXcodeOpen: genXcode
	open *.xcodeproj


genXcode:
	swift package generate-xcodeproj --enable-code-coverage --skip-extra-files 


precommit: lint genLinuxTests