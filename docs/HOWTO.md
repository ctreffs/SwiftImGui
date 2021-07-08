# Wrap cimgui

For the time beeing it is not possible to wrap cimgui out of the box fully automated.
Some manual steps are stil neccessary.
This file serves more as a reminder to me, so don't expect it to be complete.

### Steps

0. Be sure to clone with clone recursive: `git clone --recursive git@github.com:ctreffs/SwiftImGui.git`
1. In submodule 3rdparty/cimgui
	0. `git submodule update --init --recursive` 
	1. Update to latest master from <https://github.com/cimgui/cimgui>
2. In repo make new feature branch
3. Commit updated submodule pin
4. Run `make update`
5. Build, fix and run
6. Update README.md
7. Commit, push, tag, release 
