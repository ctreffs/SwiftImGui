# How To Wrap cimgui

For the time being it is not possible to wrap cimgui out of the box. This process is not fully automated.
Some manual steps are stil neccessary.
This file serves more as a reminder to me, so don't expect it to be complete.

### Notes
- It is not recommended to manually edit these files. They are auto generated after `make update`.
  - `3rdparty/cimgui` (git submodule)
  - `Sources/CImGui`
  - `Sources/ImGui`
  - `Sources/AutoWrapper/Assets/definitions.json`
- You should update these files if you see new errors after `make update`.
  - `Sources/AutoWrapper` (excepts `definitions.json`)
  - `patch_fix_ifdefs.diff`

### Steps

1. Fork and clone! Be sure to clone SwiftImGui recursively by `git clone --recursive ...`
2. Before start, try running `make lint`, `make setupEnv`, and `make build-release`
    - If `brew install luajit` fails, try `brew install luajit --HEAD` ([neovim #13529](https://github.com/neovim/neovim/issues/13529))
3. Make new feature branch in SwiftImGui. Example: `git checkout -b update-1.82`
4. Update submodule cimgui
    - In `3rdparty/cimgui` run `git submodule update --init --recursive`
    - Make sure it is up to the latest commit in [master branch](https://github.com/cimgui/cimgui)
    - Make sure the imgui version inside 3rdparty/cimgui is up to date as well
    - You should have a clean workplace after these steps 🤔
5. Commit updated submodule changes
6. Run `make update` and if you see errors, please try to fix them
    - For patch fix issues, update `patch_fix_ifdefs.diff` to match the new differences
    - For unresolved identifiers, you can update `Exceptions.swift`
    - Re-run `make update` until it does not show errors
    - Otherwise, open an issue and pull request for help
7. Build and run the demos 🍻
8. Update the provided backend files if there are major changes in the [original backend files](https://github.com/ocornut/imgui/tree/master/backends)
9. Update `README.md` and this file
10. Commit, push, tag, release 🎉
