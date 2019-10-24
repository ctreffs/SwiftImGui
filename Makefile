imgui_src := 3rdparty/cimgui
imgui_build := 3rdparty/cimgui-build
c_imgui_src := Sources/CImGUI
c_imgui2_src := Sources/CImGUI2
 #-build

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

libImGui: cleanLibImGui buildLibImGui copyLibImGui
	$(MAKE) -C $(imgui_src) clean
	rm -rdf $(imgui_build)

buildLibImGuiStatic:
	$(MAKE) -C $(imgui_src) all
	ar -cvq $(imgui_src)/libcimgui.a $(imgui_src)/cimgui.o $(imgui_src)/imgui/imgui.o $(imgui_src)/imgui/imgui_draw.o $(imgui_src)/imgui/imgui_demo.o $(imgui_src)/imgui/imgui_widgets.o

buildLibImGui:
	cmake -S $(imgui_src) -B $(imgui_build) -DIMGUI_STATIC:STRING=yes -Wdev -Werror=dev # -G "Unix Makefiles"
	$(MAKE) -C $(imgui_build) all
	mv $(imgui_build)/cimgui.a $(imgui_build)/libcimgui.a

cleanLibImGui:
	rm -rdf $(imgui_build)
	$(MAKE) -C $(imgui_src) clean

copyLibImGui:
	cp $(imgui_src)/*.h $(c_imgui_src)/include
	cp $(imgui_build)/*.a $(c_imgui_src)/lib

copyLibImGui2:
	cp $(imgui_src)/imgui/*.h $(c_imgui2_src)/imgui
	cp $(imgui_src)/imgui/*.cpp $(c_imgui2_src)/imgui
	cp $(imgui_src)/generator/output/cimgui.h $(c_imgui2_src)/include
	cp $(imgui_src)/generator/output/cimgui_impl.h $(c_imgui2_src)
	cp $(imgui_src)/generator/output/cimgui.cpp $(c_imgui2_src)

generateCInterface:
	cd $(imgui_src)/generator && luajit ./generator.lua gcc glfw opengl3 opengl2 sdl

generateCInterface2:
	cd $(imgui_src)/generator && luajit ./generator.lua nocompiler glfw opengl3 opengl2 sdl

	
cleanCLibImGui:
	rm -rdf $(c_imgui_src)/lib/*.a
	rm -rdf $(c_imgui_src)/include/*.h

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

updateCLibImGUI:
	git submodule init $(imgui_src)
	git submodule update --recursive $(imgui_src)

genXcode:
	swift package generate-xcodeproj --enable-code-coverage --skip-extra-files 


precommit: lint genLinuxTests


	#$(MAKE) -C $(imgui_src) clean
	#$(MAKE) -C $(imgui_src)
	#cd $(imgui_src) && 
	#	ar -cvq libcimgui.a cimgui.o ./imgui/imgui.o ./imgui/imgui_draw.o ./imgui/imgui_demo.o ./imgui/imgui_widgets.o && 
	#	mv -f libcimgui.a $(c_imgui_src)/lib &&
	#$(MAKE) -C $(imgui_src) clean