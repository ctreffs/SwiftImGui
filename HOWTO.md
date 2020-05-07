# Wrap cimgui

For the time beeing it is not possible to wrap cimgui out of the box fully automatically.
Some manual steps are neccessary.
This file serves more as a reminder to me, so don't expect it to be complete.

### Steps

1. In submodule 3rdparty/cimgui
	1. Merge latest master from <https://github.com/cimgui/cimgui>
	2. Apply fixes if neccessary (i.e. generator.sh updates or #defines - see i.e. Adjust generator to include the correct defs	78ebaaf	Christian Treffs <ctreffs@gmail.com>	24. Oct 2019 at 16:03)
	3. Commit and push to generator-fix branch
2. In repo make new feature branch
3. Commit updated submodule pin
4. Run `make generateCInterface` (generates new cimgui.* files)
5. Run `make copyLibImGui` (copies generated files into Sources/CImGui/)
6. Commit updated CImGui files
7. Repeat until no compile errors:
	1. Add exceptions to `Sources/AutoWrapper/Exceptions.swift`
	2. Refactor stuff in AutoGenerator if neccessary.
	3. Run `make lint`
	4. Run `make wrapLibImGui` (builds the AutoGenerator and generates Swift files)
8. Build and run demos
9. Update README
10. Commit, push, tag, release 
