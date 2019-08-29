# Interactive helpers for Android kernel development
# Copyright (C) 2019 Danny Lin <danny@kdrag0n.dev>
#
# This script must be *sourced* from a Bourne-compatible shell in order to
# function. Nothing will happen if you execute it.
#
# Source a compiler-specific setup script for proper functionality. This is
# only a base script and does not suffice for kernel building without the
# flags that compiler-specific scripts append to kmake_flags.
#


#### CONFIGURATION ####

# Kernel name
kernel_name="KingKernel"

# Defconfig name
defconfig="king_defconfig"

# Target architecture
arch="arm64"

# Base kernel compile flags (extended by compiler setup script)
kmake_flags=(
	-j"${jobs:-6}"
	ARCH="$arch"
	O="out"
)

# Target device name to use in flashable package names
device_name="marlin"

#### BASE ####

# Index of all variables and functions we set
# This allows us to clean up later without restarting the shell
_ksetup_vars+=(
	kernel_name
	defconfig
	arch
	kmake_flags
	device_name
	lan_ssh_host
	vpn_ssh_host
	kroot
	_ksetup_vars
	_ksetup_functions
	_ksetup_old_ld_path
	_ksetup_old_path
)
_ksetup_functions+=(
	msg
	croot
	get_clang_version
	get_gcc_version
	buildnum
	zerover
	zver
	kmake
	mkzip
	dzip
	rel
	crel
	cleanbuild
	incbuild
	dbuild
	ktest
	sktest
	vsktest
	inc
	pinc
	sinc
	vsinc
	psinc
	pvsinc
	dc
	cpc
	mc
	cf
	ec
	osize
	glink
	unsetup
	utree
)

# Get kernel repository root for later use
kroot="$PWD/$(dirname "$0")"

# Show an informational message
function msg() {
    echo -e "\e[1;32m$1\e[0m"
}

# Go to the root of the kernel repository repository
function croot() {
	cd "$kroot"
}

# Get the version of Clang in an user-friendly form
function get_clang_version() {
	"$1" --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//'
}

# Get the version of GCC in an user-friendly form
function get_gcc_version() {
	"$1" --version | head -n 1 | cut -d'(' -f2 | tr -d ')' | sed -e 's/[[:space:]]*$//'
}


#### VERSIONING ####

# Get the current build number
function buildnum() {
	cat "$kroot/out/.version"
}

# Reset the kernel version number
function zerover() {
	rm "$kroot/out/.version"
}

# Retrieve the kernel version from a flashable package
function zver() {
	unzip -p "$1" Image.gz | gunzip -dc | strings | grep "Linux version [[:digit:]]"
}


#### COMPILATION ####

# Make wrapper for kernel compilation
function kmake() {
	make "${kmake_flags[@]}" "$@"
}


#### PACKAGE CREATION ####

# Create a flashable package of the current kernel image at the specified path
function mkzip() {
	# Copy Kernel image to AK3 directory
	cp "$kroot/out/arch/$arch/boot/Image.lz4" "$kroot/AnyKernel3/"
		
	# Copy device tree blobs and remove extraneous files
	rm -fr "$kroot/AnyKernel3/dtbs"
	mkdir "$kroot/AnyKernel3/dtbs"
	cp -r "$kroot/out/arch/$arch/boot/dts/htc/." "$kroot/AnyKernel3/dtbs/"
	rm -fr "$kroot/AnyKernel3/dtbs/*.tmp"
	rm -fr "$kroot/AnyKernel3/dtbs/modules.order"
}

#### KERNEL CONFIGURATION ####

# Show differences between the committed defconfig and current config
function dc() {
	diff "arch/$arch/configs/$defconfig" "$kroot/out/.config"
}

# Update the defconfig with the current config
function cpc() {
	cat "$kroot/out/.config" >| "arch/$arch/configs/$defconfig"
}

# Reset the current config to the committed defconfig
function mc() {
	kmake "$defconfig"
}

# Open an interactive config editor
function cf() {
	kmake nconfig
}

# Edit the raw text config
function ec() {
	"${EDITOR:-vim}" "$kroot/out/.config"
}

