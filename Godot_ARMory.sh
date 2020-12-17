#!/bin/bash
# Version 1.0.0
# Shell script for configuring ARM linux computers for building the Godot Game Engine.
# It also patches Open Image Denoiser to use Neon instructions instead of 
# This script has been tested on the following devices with the following script and godot versions:
# * Nvidia Jetson Nano A0 - 1.0.0 - godot 4.0 Pre-Release
# 
# David Johnston - 15/Dec/2020

# Install necessary packages from apt
sudo apt update -y
sudo apt upgrade -y
sudo apt install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libfreetype6-dev libssl-dev libudev-dev libxi-dev libxrandr-dev yasm clang python3 python3-pip git wget -y

# Install scons from pip
pip3 install scons

# Make sure scons is using python3
sudo sed -i 's;#! /usr/bin/python$;#! /usr/bin/python3;' $(which scons)
sudo sed -i 's;#!/usr/bin/python$;#!/usr/bin/python3;' $(which scons)

# Clone godot TODO: Change this to be a specific release. This will probably happen after Godot 4.0 is released
git clone https://github.com/godotengine/godot
cd godot

# Patch Open Image Denoiser to Use Neon (ARM) instead of SSE (Intel x86-64/AMD64)
wget https://raw.githubusercontent.com/DLTcollab/sse2neon/master/sse2neon.h
sed -i 's;^#include <xmmintrin.h>;#include "sse2neon.h" //Patch for arm systems. Original: #include <xmmintrin.h>;' thirdparty/oidn/common/platform.h

# Build Godot Editor
scons platform=linuxbsd tools=yes target=release_debug use_llvm=no -j8 ; scons -c # 8 threads used because most SBCs have between 4-8 cores. This will make sure they are all used for building.

# Build Godot Export Templates
#{scons platform=linuxbsd tools=no target=release use_llvm=no && mv bin/godot.linuxbsd.opt.64 bin/linux_x11_64_release} ; scons -c
scons platform=linuxbsd tools=no target=release use_llvm=no -j8 ; scons -c
#{scons platform=linuxbsd tools=no target=release_debug use_llvm=no && mv bin/godot.linuxbsd.opt.64 bin/linux_x11_64_debug} ; scons -c
scons platform=linuxbsd tools=no target=release_debug use_llvm=no -j8 ; scons -c
