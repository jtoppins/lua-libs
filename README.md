---
layout: default
title: Home
permalink: /
---

# DCS Extensions (DCSEx)

A set of LUA classes and functions that extend the DCS mission scripting
environment so richer missions can be created.

## Contribution Guide

Contributions can be made with a github pull request but features and/or
changes need to be discussed first. Code is licensed under LGPLv3 and
contributions must be licensed under the same. For any issues or feature
requests please use the issue tracker and file a new issue. Make sure to
provide as much detail about the problem or feature as possible. New
development is done in feature branches which are eventually merged into
`master`, base your features and fixes off `master`.

### Setup the Development Environment

The easiest way to setup the development environment is to use Windows
Subsystem for Linux. Do this by starting a powershell console by
hitting keys Win+r and type `powershell`. Once in the shell, run the
following command:

```bash
wsl --install -d "Debian"
```

If you are having trouble see
[Microsoft's help](https://learn.microsoft.com/en-us/windows/wsl/install).
See also [WSL devel env setup](https://learn.microsoft.com/en-us/windows/wsl/setup/environment#set-up-your-linux-username-and-password).

After you have setup your Linux user you can run the following commands
in a bash prompt to finalize the setup. It is assumed you are using
Debian.

```bash
cd ~
apt install -y git
git clone https://github.com/jtoppins/lua-libs.git
cd lua-libs
./scripts/devel-setup
```

The `devel-setup` script will attempt to install additional packages that
lua-libs uses to run unit-tests and install code directly from the source tree.

## Installation

This script library can be installed into `<SAVED_GAMES>/DCS/Scripts`. The
[release zip](https://github.com/jtoppins/lua-libs/releases/latest) should
be able to be unzipped right into the DCS saved games folder.

### Modifying `MissionScripting.lua`

You can find the `MissionScripting.lua` file in the game install directory
under `Scripts`. This file must be modified to load all script libraries
of DCSEx. DCSEx attempts to make this rather easy by only needing to add
a single line to the `MissionScripting.lua` file.

```diff
  --Initialization script for the Mission lua Environment (SSE)

  dofile('Scripts/ScriptingSystem.lua')
+ dofile(lfs.writedir()..'Scripts/loadplugins.lua')

  --Sanitize Mission Scripting environment
  --This makes unavailable some unsecure functions.
  --Mission downloaded from server to client may contain potentialy harmful lua code that may use these functions.
  --You can remove the code below and make availble these functions at your own risk.

  local function sanitizeModule(name)
    _G[name] = nil
    package.loaded[name] = nil
  end

  do
    sanitizeModule('os')
    sanitizeModule('io')
    sanitizeModule('lfs')
    _G['require'] = nil
    _G['package'] = nil
  end
```

This preserves the environment sanitization so any scripts existing in
mission files are still limited.

### Exporting other Libraries

Additional libraries can be exported to the mission environment by
modifying the `<SAVED_GAMES>/DCS/Config/missionplugins.cfg` file
to include the list of addition libraries that you want loaded.

## Library Overhead

Other than a small amount of additional memory used to load DCSEx and
store its byte-code in memory. No additional processes or auto-indexing
are started behind the scenes unlike other frameworks/libraries. DCSEx
will just sit in memory until something calls one of its functions.

## Contact Us

* [discord](https://discord.gg/kG38MDqDrN)
