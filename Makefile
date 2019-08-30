lint:
	swiftlint autocorrect
	swiftlint

genTests:
	swift test --generate-linuxmain
	swiftlint autocorrect

updateDependencies:
	git submodule update --init --recursive



cimguiStaticLib:
	# FIXME: this needs to be run from within the cimgui folder.
	ar -cvq libcimgui.a cimgui.o ./imgui/imgui.o ./imgui/imgui_draw.o ./imgui/imgui_demo.o ./imgui/imgui_widgets.o
