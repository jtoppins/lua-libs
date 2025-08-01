MAKEFLAGS := --no-print-directory

PHONY := __all
__all:

unexport LC_ALL
unexport GREP_OPTIONS

this-makefile := $(lastword $(MAKEFILE_LIST))
srctree := $(realpath $(dir $(this-makefile)))

# Beautify output
# ----------------------------------------------------------------
# Build commands start with "cmd_". You can optionally define
# "quiet_cmd_*". If defined, the short log is printed. Otherwise, no log from
# that command is printed by default.
#
# e.g.)
#    quiet_cmd_install = INSTALL  $(SOURCE)
#          cmd_install = $(INSTALL) $(SOURCE) $(DEST)
#
# A simple variant is to prefix commands with $(Q) - that's useful
# for commands that shall be hidden in non-verbose mode.
#
#    $(Q)$(INSTALL) foo
#
# If BUILD_VERBOSE contains 1, the whole command is echoed.
# Use 'make V=1' to see the full commands

ifeq ("$(origin V)", "command line")
	BUILD_VERBOSE = $(V)
endif

quiet = quiet_
Q = @

ifneq ($(findstring 1, $(BUILD_VERBOSE)),)
	quiet =
	Q =
endif

# If the user is running make -s (silent mode), suppress echoing of
# commands
ifneq ($(findstring s,$(firstword -$(MAKEFLAGS))),)
quiet=silent_
override BUILD_VERBOSE :=
endif

export quiet Q BUILD_VERBOSE

cmd = $(if $(Q),@set -e; echo "$(quiet_cmd_$(1))"; $(cmd_$(1)),$(cmd_$(1)))

# prefix is used to change the install target
INSTALLPREFIX := $(if $(PREFIX), "$(PREFIX)"/,)
PROJ_VERSION  ?= $(shell git describe)

LUA_PATH := $(CURDIR)/src/?.lua;;
export LUA_PATH

# Make variables
INSTALL               = install
INSTALLFLAGS          = --compare
ZIP                   = zip
TAR                   = tar
SED                   = sed
LUA                   = lua5.1
LUACC                 = luac
LUACHECK              = luacheck
LUACHECK_OPTS         = $(if $(Q),-q)
LUATESTS              = busted
TZ                    = "UTC 0"

export PREFIX PROJ_VERSION
export INSTALL INSTALLFLAGS ZIP TAR SED LUA LUACC LUACHECK LUABUSTED TZ
export LUACHECK_OPTS

quiet_cmd_rmfiles = CLEAN  $(rm-files)
      cmd_rmfiles = rm -rf $(rm-files)

generated_files := src/libs.lua
rm-files := $(generated_files)
install-targets = lib_install

PHONY += all
__all: all

PHONY += all
all: generated

PHONY += generated
generated: $(generated_files)

PHONY += check syntax tests
check: syntax tests

syntax: generated
	$(Q)$(LUACHECK) $(LUACHECK_OPTS) src tests
	$(Q)git diff --check

tests: generated
	$(Q)(cd tests; busted)

PHONY += docs
docs: generated
	@echo 'not implemented yet.'

PHONY += help
help:
	@echo 'Targets:'
	@echo '  clean        - Remove all built artifacts'
	@echo '  check        - Run all unit tests and syntax checks'
	@echo '  syntax       - Run luacheck lint checker'
	@echo '  tests        - Run unit tests'
	@echo '  docs         - Build documentation'

PHONY += clean
clean:
	$(call cmd,rmfiles)

quiet_cmd_rmfiles = CLEAN  $(rm-files)
      cmd_rmfiles = rm -rf $(rm-files)

quiet_cmd_genfile = GEN    $@
      cmd_genfile = \
		$(SED) -e "s:%VERSION%:$(PROJ_VERSION):" $< > $@

$(generated_files): %.lua: %.lua.in
	$(call cmd,genfile)

.PHONY: $(PHONY)
