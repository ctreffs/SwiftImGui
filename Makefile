lint:
	swiftlint autocorrect --format
	swiftlint lint --quiet

genLinuxTests:
	swift test --generate-linuxmain
	swiftlint autocorrect --format --path Tests/

test: genLinuxTests
	swift test

updateDependencies:
	git submodule update --init --recursive

buildCImGUIStaticLib:
	$(MAKE) -C "Sources/CImGUI/cimgui/" clean
	$(MAKE) -C "Sources/CImGUI/cimgui/"
	cd "Sources/CImGUI/cimgui/";  ar -cvq libcimgui.a cimgui.o ./imgui/imgui.o ./imgui/imgui_draw.o ./imgui/imgui_demo.o ./imgui/imgui_widgets.o; mv -f libcimgui.a ../lib/
	$(MAKE) -C "Sources/CImGUI/cimgui/" clean


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