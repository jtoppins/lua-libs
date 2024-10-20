MAKEFLAGS := --no-print-directory
VERSION   ?= $(shell git describe)

LUA_PATH := $(CURDIR)/src/?.lua;;
export LUA_PATH

.PHONY: help check check-syntax tests build docs
help:
	@echo 'Targets:'
	@echo '  check        - Run all unit tests and syntax checks'
	@echo '  check-syntax - Run luacheck lint checker'
	@echo '  tests        - Run unit tests'
	@echo '  build        - Build a releasable package, including docs'
	@echo '  docs         - Build documentation'

check-syntax:
	luacheck -q src tests

tests:
	@$(MAKE) -C tests

check: check-syntax tests

docs:
	@echo 'no docs to generate'

build: docs
	@echo 'no build steps yet'
