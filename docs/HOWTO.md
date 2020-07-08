# Wrap cimgui

For the time beeing it is not possible to wrap cimgui out of the box fully automated.
Some manual steps are stil neccessary.
This file serves more as a reminder to me, so don't expect it to be complete.

### Steps

0. Be sure to clone with clone recursive: `git clone --recursive git@github.com:ctreffs/SwiftImGui.git`
1. In submodule 3rdparty/cimgui
	0. `git submodule update --init --recursive` 
	1. Merge latest master from <https://github.com/cimgui/cimgui>
	2. Apply fixes if neccessary (i.e. generator.sh updates or #defines - see i.e. Adjust generator to include the correct defs	78ebaaf	Christian Treffs <ctreffs@gmail.com>	24. Oct 2019 at 16:03)
	3. Commit and push to generator-fix branch
2. In repo make new feature branch
3. Commit updated submodule pin
4. Run `make generateCInterface` (generates new cimgui.* files)
5. Run `make copyLibImGui` (copies generated files into Sources/CImGui/)
6. Recompile
	7. If anything does not compile reset changes in `cimgui.h` to:

		``` 
			+#ifndef CIMGUI_DEFINE_ENUMS_AND_STRUCTS.
			-#ifdef CIMGUI_DEFINE_ENUMS_AND_STRUCTS
		```

6. Commit updated CImGui files
7. Repeat until no compile errors:
	1. Add exceptions to `Sources/AutoWrapper/Exceptions.swift`
	2. Extend stuff in AutoGenerator if neccessary.
	3. Run `make lint`
	4. Run `make wrapLibImGui` (builds the AutoGenerator and generates Swift files)
8. Build, fix and run demos
9. Update README.md
10. Commit, push, tag, release 
