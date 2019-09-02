lint:
	swiftlint autocorrect
	swiftlint

genTests:
	swift test --generate-linuxmain
	swiftlint autocorrect

updateDependencies:
	git submodule update --init --recursive



buildCImGUIStaticLib:
	$(MAKE) -C "Sources/CImGUI/cimgui/" clean
	$(MAKE) -C "Sources/CImGUI/cimgui/"
	cd "Sources/CImGUI/cimgui/";  ar -cvq libcimgui.a cimgui.o ./imgui/imgui.o ./imgui/imgui_draw.o ./imgui/imgui_demo.o ./imgui/imgui_widgets.o; mv -f libcimgui.a ../lib/
	$(MAKE) -C "Sources/CImGUI/cimgui/" clean