LUA ?= lua

tidy = $(LUA) scripts/tidy.lua

default: help

changelog:
	git-cliff --output CHANGELOG.md
	$(tidy) CHANGELOG.md

help:
	@echo "Available targets:"
	@echo "  help                 print this help"
	@echo "  changelog            regenerate CHANGELOG.md"
