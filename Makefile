lint:
	swiftlint autocorrect
	swiftlint

updateDependencies:
	git submodule update --init --recursive