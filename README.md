# LUA Library

A set of LUA primitives.

## Contribution Guide

Contributions can be made with a github pull request but features and/or
changes need to be discussed first. Code is licensed under LGPLv3 and
contributions must be licensed under the same. For any issues or feature
requests please use the issue tracker and file a new issue. Make sure to
provide as much detail about the problem or feature as possible. New
development is done in feature branches which are eventually merged into
`master`, base your features and fixes off `master`.

### Setup the Development Environment

The easiest way to install DCT is to use Windows Subsystem for Linux.
Do this by starting a powershell console by hitting keys Win+r and
type `powershell`. Once in the shell, run the following commands:

```bash
wsl --install -d "Debian"
```

If you are having trouble see
[Microsoft's help](https://learn.microsoft.com/en-us/windows/wsl/install).
See also [WSL devel env setup](https://learn.microsoft.com/en-us/windows/wsl/setup/environment#set-up-your-linux-username-and-password).

After you have setup your Linux user you can run the following commands in
a bash prompt to finalize the DCT setup. It is assumed you are using Debian.

```bash
cd ~
apt install -y git
git clone https://github.com/jtoppins/lua-libs.git
cd lua-libs
./scripts/devel-setup
```

The `devel-setup` script will attempt to install additional packages that
lua-libs uses to run unit-tests and install code directly from the source tree.

## Contact Us

* [DCT discord](https://discord.gg/kG38MDqDrN)
