lint:
	swiftlint autocorrect
	swiftlint

genTests:
	swift test --generate-linuxmain
	swiftlint autocorrect

updateDependencies:
	git submodule update --init --recursive