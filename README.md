# Godot_ARMory
Godot ARMory is a shell script that will build Godot Game Engine 4.0 for an ARM Linux computer, such as a Raspberry Pi or Jetson Nano. It downloads the necessary tools and software, patches OIDN for ARM and runs the commands necessary to build the editor and export templates. It was built because I have a game in mind that I want to deploy on a Jetson Nano, so I needed a game engine that I could port easily. This meant using an open source project, and using Godot seemed like it would work. Godot 4.0 is adding Vulkan support, so projects should be able to leverage both the high end rendering features offered to top of the line PCs and the performance improvement for resource constrained single board computers.

Credit goes to Krzysztof Jankowski at bits.p1x.in for his Godot 3.2.3 instructions for the Raspberry pi 4 and John Ratcliff at Code Suppository for his wonderful sse2neon library.

## Compatibility
Godot ARMory has been tested with the following devices.

| Device | OS(es) | Godot Version | Script Version |
| --- | --- | --- | --- |
| NVIDIA Jetson Nano - A02 | Official NVIDIA Custom Ubuntu Image | 4.0 Pre-Release (12/15/2020) | 1.0.0

## Usage
DO NOT ATTEMPT TO USE THIS SCRIPT ON A DEVICE WITH A STORAGE DEVICE SMALLER THAN 64GB. IT **WILL FAIL** DUE TO RUNNING OUT OF SPACE. IT MAY ALSO MAKE SYSTEMS UNUSABLE DUE TO LOW STORAGE
It is NOT recommended to build Godot using Godot ARMory on a system actively in use. Instead, it is recommended to flash a new SD Card, build Godot, and then install it on production systems.

Set up your favorite single board computer as you normally would (with a fresh install) and run 
```
curl -sS https://raw.githubusercontent.com/Gator-Boy11/Godot_ARMory/main/Godot_ARMory.sh | bash
```
on the device. The script will handle everything from there, so go ahead and get some sleep (it will probably take several hours to build everything) and come back to your brand new Godot build, fresh out of the ARMory!

## Manual Building
Want more control over how your Godot is built? Here is what you need to do.

1. Install the necessary packages from apt (or your preferred package manager) and pip.  
```
sudo apt update  
sudo apt upgrade  
sudo apt install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libfreetype6-dev libssl-dev libudev-dev libxi-dev libxrandr-dev yasm clang python3 python3-pip  
pip3 install scons
```
2. Patch SCons to use Python 3. This can be done either by changing line 1 of the SCons script to `#!/usr/bin/python3` or by simply running the commands below.
```
sudo sed -i 's;#! /usr/bin/python$;#! /usr/bin/python3;' $(which scons)
sudo sed -i 's;#!/usr/bin/python$;#!/usr/bin/python3;' $(which scons)
```
3. Download the Godot source from the Github repository and extract it.

4. Patch OIDN. First, download sse2neon.h from the Github repository and place it in your godot source directory. Then comment out the line in `thirdparty/oidn/common/platform.h` that says `#include <xmmintrin.h>` and add a line that says `#include "sse2neon.h"`

5. Build Godot as you normally would for Linux. It is recommended to run `scons -c` after every build to prevent the build from taking up unnecessary space. Don't set the bits parameter.

## Patches
The main reason to use this script is to apply a few patches needed for ARM based CPUs.

The first is the build system SCons, which must be patched to use Python 3. Some systems use Python 2 by default, so the script patches the scons script by changing the shebang on line 1 to use Python 3.

Next, the third party component Open Image De-Noiser (OIDN) used by Godot 4.0 must be patched to not use SSE, an instruction set that is part of most if not all modern x86 CPUs, but is not present on ARM due to the different architectures. The script downloads sse2neon.h, a library that converts many SSE instructions to Neon instructions, the ARM equivalent of SSE. The script then changes the include statement in OIDN to use sse2neon.h instead of xmmintrin.h, the SSE library.
