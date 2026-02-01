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
# "quiet_cmd_*". If defined, the short log is printed. Otherwise,
# no log from that command is printed by default.
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
INSTALLPREFIX = $(if $(PREFIX), "$(PREFIX)"/,)
MODNAME       := dcsext
PROJ_VERSION  ?= $(shell git describe)

LUA_PATH := $(CURDIR)/src/?.lua;$(CURDIR)/scripts/?.lua;;
export LUA_PATH

# Make variables
INSTALL               = install
INSTALLFLAGS          = --compare
ZIP                   = zip
ZIP_OPTS              = $(if $(Q),-q)
TAR                   = tar
SED                   = sed
LUA                   = lua5.1
LUACC                 = luac
LUACHECK              = luacheck
LUACHECK_OPTS         = $(if $(Q),-q)
LUATESTS              = busted
LUADOC                = ldoc
LUADOC_OPTS           = $(if $(Q),-q) -i
TZ                    = "UTC 0"
DISTPREFIX            := .build
SCRIPTS_INSTALL_PATH  = $(INSTALLPREFIX)Scripts
CONFIGS_INSTALL_PATH  = $(INSTALLPREFIX)Config

export PREFIX PROJ_VERSION
export INSTALL INSTALLFLAGS ZIP TAR SED LUA LUACC LUACHECK LUATESTS TZ
export LUACHECK_OPTS LUADOC LUADOC_OPTS

generated_docs := docs/_reference
generated_sources := src/$(MODNAME).lua
source_files := $(generated_sources)
source_files += $(filter %.lua, $(wildcard src/$(MODNAME)/* src/$(MODNAME)/*/*))
rm-files := $(generated_docs) $(generated_sources)
install-targets := mod_install

PHONY += all
__all: all

PHONY += all
all: generated

PHONY += generated generated-docs
generated: $(generated_sources)
generated-docs: $(generated_docs)

PHONY += install mod_install
mod_install: generated
	$(if $(PREFIX),$(call cmd,mod_install),$(error PREFIX not defined.))

install: $(install-targets)

PHONY += uninstall
uninstall:
	$(if $(PREFIX),$(call cmd,mod_remove),$(error PREFIX not defined.))

PHONY += dist
dist: $(MODNAME)-$(PROJ_VERSION).zip

$(MODNAME)-$(PROJ_VERSION).zip: PREFIX=$(DISTPREFIX)
$(MODNAME)-$(PROJ_VERSION).zip: install
	$(call cmd,distzip)

PHONY += check syntax tests
check: syntax tests

syntax: generated
	$(Q)$(LUACHECK) $(LUACHECK_OPTS) src tests scripts/gendocs
	$(Q)git diff --check

tests: generated
	$(Q)(cd tests; $(LUATESTS))

PHONY += docs
docs: generated generated-docs

PHONY += clean distclean
distclean: clean
	$(Q)rm -rf $(DISTPREFIX)
	$(Q)rm -f *.zip

clean:
	$(call cmd,rmfiles)

PHONY += help
help:
	@echo 'Targets:'
	@echo '  clean        - Remove all built artifacts'
	@echo '  distclean    - Remove packaged artifacts'
	@echo '  check        - Run all unit tests and syntax checks'
	@echo '  syntax       - Run luacheck lint checker'
	@echo '  tests        - Run unit tests'
	@echo '  docs         - Build documentation'
	@echo '  install      - Install mod into the directory specified by'
	@echo '                 PREFIX'
	@echo '  uninstall    - Uninstall mod that was installed to PREFIX'
	@echo '  dist         - Build a releasable package, including docs'
	@echo ''
	@echo 'Variables:'
	@echo '  PREFIX       - the location where you want the mod installed'
	@echo ''
	@echo 'Example:'
	@echo '  make install PREFIX=/mnt/c/Users/userfoo/Saved\ Games/DCS'
	@echo ''
	@echo 'This will install mod into "userfoo" saved games folder'

quiet_cmd_distzip     = ZIP     $@
      cmd_distzip     = \
		(cd $(PREFIX); $(ZIP) $(ZIP_OPTS) -r .; mv zip.zip ../$@)

quiet_cmd_mod_remove  = RM      $@
      cmd_mod_remove  = \
		rm -rf $(SCRIPT_INSTALL_PATH)/$(MODNAME)* \
			$(SCRIPTS_INSTALL_PATH)/loadplugins.lua

quiet_cmd_mod_install = INSTALL $(MODNAME) PREFIX=$(PREFIX)
      cmd_mod_install = \
		mkdir -p $(SCRIPTS_INSTALL_PATH); \
		mkdir -p $(CONFIGS_INSTALL_PATH); \
		cp -aL "$(srctree)"/src/* $(SCRIPTS_INSTALL_PATH); \
		$(INSTALL) $(INSTALLFLAGS) -m 644 -t $(SCRIPTS_INSTALL_PATH) \
			"$(srctree)"/scripts/loadplugins.lua; \
		$(INSTALL) $(INSTALLFLAGS) --backup=numbered -m 644 \
			-t $(CONFIGS_INSTALL_PATH) \
			"$(srctree)"/config/missionplugins.cfg; \
		find $(INSTALLPREFIX) \( -name '*.lua.in' \) -type f \
			-exec rm -rf {} +

quiet_cmd_rmfiles = CLEAN   $(rm-files)
      cmd_rmfiles = rm -rf $(rm-files)

quiet_cmd_genfile = GEN     $@
      cmd_genfile = \
		$(SED) -e "s:%VERSION%:$(PROJ_VERSION):" $< > $@

$(generated_sources): %.lua: %.lua.in
	$(call cmd,genfile)

quiet_cmd_gendocs = LDOC    $@
      cmd_gendocs = \
		mkdir -p $@; \
		$(LUADOC) $(LUADOC_OPTS) --filter pl.pretty.dump src | \
		scripts/gendocs --output $@ -;

$(generated_docs): $(source_files) scripts/gendocs
	$(call cmd,gendocs)

.PHONY: $(PHONY)
