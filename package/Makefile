LUA ?= lua

ver = $(LUA) scripts/ver.lua
tidy = $(LUA) scripts/tidy.lua

package_version = $(shell $(ver))

default: help

changelog:
	git-cliff --output @NAME@/CHANGELOG.md --tag $(package_version)
	$(tidy) CHANGELOG.md

publish:
	git branch -D upm
	git subtree split --prefix=@NAME@ -b upm
	git tag -f $(package_version) upm
	git push --force -u origin upm
	git push --force --tag

help:
	@echo "Available targets:"
	@echo "  help                 print this help"
	@echo "  changelog            regenerate CHANGELOG.md"
	@echo "  public               publish the package to its own branch"
