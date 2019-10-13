imgui_src := 3rdparty/cimgui
imgui_build := 3rdparty/cimgui
c_imgui_src := Sources/CImGUI
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
	#$(MAKE) -C $(imgui_src) clean

buildLibImGui:
	$(MAKE) -C $(imgui_src) all
	ar -cvq $(imgui_src)/libcimgui.a $(imgui_src)/cimgui.o $(imgui_src)/imgui/imgui.o $(imgui_src)/imgui/imgui_draw.o $(imgui_src)/imgui/imgui_demo.o $(imgui_src)/imgui/imgui_widgets.o

buildLibImGui2:
	cmake -S $(imgui_src) -B $(imgui_build) -DIMGUI_STATIC:STRING=yes -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS:NUMBER=1 -Wdev -Werror=dev # -G "Unix Makefiles"
	$(MAKE) -C $(imgui_build) all

cleanLibImGui:
	#rm -rdf $(imgui_build)
	$(MAKE) -C $(imgui_src) clean

copyLibImGui:
	cp $(imgui_src)/*.h $(c_imgui_src)/include
	cp $(imgui_build)/*.a $(c_imgui_src)/lib
	
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


genXcode:
	swift package generate-xcodeproj --enable-code-coverage --skip-extra-files 


precommit: lint genLinuxTests


	#$(MAKE) -C $(imgui_src) clean
	#$(MAKE) -C $(imgui_src)
	#cd $(imgui_src) && 
	#	ar -cvq libcimgui.a cimgui.o ./imgui/imgui.o ./imgui/imgui_draw.o ./imgui/imgui_demo.o ./imgui/imgui_widgets.o && 
	#	mv -f libcimgui.a $(c_imgui_src)/lib &&
	#$(MAKE) -C $(imgui_src) clean