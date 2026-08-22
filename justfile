BUILD_ROOT       := "build"
NATIVE_BUILD_DIR := BUILD_ROOT + "/native"
WIN_BUILD_DIR    := BUILD_ROOT + "/win"
TOOLCHAIN_WIN32  := "toolchains/mingw-toolchain.cmake"

alias help := default

# List this help
default:
    @just --list

# Compile natively for local Debian testing
build:
    cmake -B {{ NATIVE_BUILD_DIR }} -S .
    cmake --build {{ NATIVE_BUILD_DIR }} -v

# Cross-compile for Windows target (DCS World .dll)
build-windows:
    cmake -B {{ WIN_BUILD_DIR }} -S . -DCMAKE_TOOLCHAIN_FILE={{ TOOLCHAIN_WIN32 }}
    cmake --build {{ WIN_BUILD_DIR }} -v

# Build all targets
build-all: build build-windows

# Clean all build artifacts
clean:
    rm -rf {{ BUILD_ROOT }}

# Package the assets for DCS World deployment
dist: build-windows
	@echo "TODO"; exit 1
