#!/usr/bin/env/bash
mkdir ~/toolchains
cd ~/toolchains

if [[ "$@" =~ "gcc" ]]; then
	git clone https://github.com/kdrag0n/aarch64-elf-gcc -b 9.x --depth=1 gcc-9.1.0
	git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=1 gcc32-9.1.0
else
	git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 --depth=1 gcc
	git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 --depth=1 gcc32
	git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 --depth=1 clang
	cd clang
	ls
	find . | grep -v 'clang-r353983e' | xargs rm -rf
	ls
	cd ..
fi
