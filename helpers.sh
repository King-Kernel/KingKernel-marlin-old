<<<<<<< HEAD
# Shared interactive kernel build helpers

# Root of the kernel repository for use in helpers
kroot="$(pwd)/$(dirname "$0")"

# Go to the root of the kernel repository
croot() {
    cd "$kroot"
}

# Determine the prefix of a cross-compiling toolchain (@nathanchance)
get_gcc_prefix() {
    local gcc_path="${1}gcc"

    # If the prefix is not already provided
    if [ ! -f "$gcc_path" ]; then
        gcc_path="$(find "$1" \( -type f -o -type l \) -name '*-gcc')"
    fi

    echo "$gcc_path" | head -n1 | sed 's@.*/@@' | sed 's/gcc//'
}

# Get the version of Clang in a user-friendly form
get_clang_version() {
    "$1" --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//'
}

# Get the version of GCC in a user-friendly form
get_gcc_version() {
    "$1" --version|head -n1|cut -d'(' -f2|tr -d ')'|sed -e 's/[[:space:]]*$//'
}

# Define the flags given to make to compile the kernel
MAKEFLAGS=(
    -j$jobs
    ARCH=arm64

    KBUILD_BUILD_USER=kingbri
    KBUILD_BUILD_HOST=kingbri1
)

# Make wrapper for kernel compilation
kmake() {
    make "${MAKEFLAGS[@]}" "$@"
}

# Move kernel image to AnyKernel dir
moveimg() {
    rm -rf AnyKernel/Image.lz4-dtb
    cp out/arch/arm64/boot/Image.lz4-dtb AnyKernel/Image.lz4-dtb
    echo "Copied image file"
}

# Move kernel image to AnyKernel dir
movevbox() {
    rm -rf $HOME/VBOX/Image.lz4-dtb
    echo "Removed old image"
    cp out/arch/arm64/boot/Image.lz4-dtb $HOME/VBOX/Image.lz4-dtb
    echo "Copied new image file, boot from windows"
}

_RELEASE=0

# Create a flashable zip of the current kernel image
mkzip() {
    [ $_RELEASE -eq 0 ] && vprefix=test
    [ $_RELEASE -eq 1 ] && vprefix=v

    cp "$kroot/out/arch/arm64/boot/Image.lz4-dtb" "$kroot/flasher/"

    [ $_RELEASE -eq 0 ] && echo "  • Installing test build $(cat "$kroot/out/.version")" >| "$kroot/flasher/version"
    [ $_RELEASE -eq 1 ] && echo "  • Installing version v$(cat "$kroot/out/.version")" >| "$kroot/flasher/version"
    echo "  • Built on $(date "+%a %b %d, %Y")" >> "$kroot/flasher/version"

    fn="${1:-proton_kernel.zip}"
    rm -f "$fn"
    echo "  ZIP     $fn"
    oldpwd="$(pwd)"
    pushd -q "$kroot/flasher"
    zip -qr9 "$oldpwd/$fn" . -x .gitignore
    popd -q
}

# Produce an incremental kernel build and package it for release
rel() {
    _RELEASE=1

    # Swap out version files
    [ ! -f "$kroot/out/.relversion" ] && echo 0 > "$kroot/out/.relversion"
    mv "$kroot/out/.version" "$kroot/out/.devversion" && \
    mv "$kroot/out/.relversion" "$kroot/out/.version"

    # Compile kernel
    kmake oldconfig # solve a "cached" config
    kmake "$@"

    # Pack zip
    mkzip "builds/ProtonKernel-pixel3-v$(cat "$kroot/out/.version").zip"

    # Revert version
    mv "$kroot/out/.version" "$kroot/out/.relversion" && \
    mv "$kroot/out/.devversion" "$kroot/out/.version"

    _RELEASE=0
}

# Produce a clean kernel build and package it for release
crel() {
    kmake clean && rel "$@"
}

# Reset the version (compile number)
zerover() {
    echo 0 >| "$kroot/out/.version"
}

# Make a clean build of the kernel and package it as a flashable zip
cleanbuild() {
    kmake clean && kmake "$@" && mkzip
}

# Incrementally build the kernel and package it as a flashable zip
incbuild() {
    kmake "$@" && mkzip
}

# Incrementally build the kernel and package it as a flashable test release zip
dbuild() {
    kmake "$@" && dzip
}

# Incrementally build the kernel, package it as a flashable test release zip, then upload it to transfer.sh
tbuild() {
    kmake "$@" && tzip
}

# Create a flashable test release zip
dzip() {
    mkzip "builds/ProtonKernel-pixel3-test$(cat "$kroot/out/.version").zip"
}

# Create a flashable test release zip, then upload it to transfer.sh
tzip() {
    dzip && transfer "builds/ProtonKernel-pixel3-test$(cat "$kroot/out/.version").zip"
}

# Flash the latest kernel zip on the connected device via ADB
ktest() {
    adb wait-for-any && \

    fn="${1:-proton_kernel.zip}"
    is_android=false
    adb shell pgrep gatekeeperd > /dev/null && is_android=true
    if $is_android; then
        adb push "$fn" /data/local/tmp/kernel.zip && \
        adb shell "su -c 'export PATH=/sbin/.core/busybox:$PATH; unzip -p /data/local/tmp/kernel.zip META-INF/com/google/android/update-binary | /system/bin/sh /proc/self/fd/0 unused 1 /data/local/tmp/kernel.zip && /system/bin/svc power reboot'"
            else
        adb push "$fn" /tmp/kernel.zip && \
        adb shell "twrp install /tmp/kernel.zip && /system/bin/svc power reboot"
    fi
}

# Flash the latest kernel zip on the device via SSH over LAN
sktest() {
    fn="proton_kernel.zip"
    [ "x$1" != "x" ] && fn="$1"

    scp "$fn" phone:tmp/kernel.zip && \
    ssh phone "/sbin/su -c 'am broadcast -a net.dinglisch.android.tasker.ACTION_TASK --es task_name \"Kernel Flash Warning\"; export PATH=/sbin/.core/busybox:$PATH; sleep 4; unzip -p /data/data/com.termux/files/home/tmp/kernel.zip META-INF/com/google/android/update-binary | /system/bin/sh /proc/self/fd/0 unused 1 /data/data/com.termux/files/home/tmp/kernel.zip && /system/bin/svc power reboot'"
}

# Flash the latest kernel zip on the device via SSH over VPN
vsktest() {
    fn="proton_kernel.zip"
    [ "x$1" != "x" ] && fn="$1"

    scp "$fn" vphone:tmp/kernel.zip && \
    ssh phone "/sbin/su -c 'am broadcast -a net.dinglisch.android.tasker.ACTION_TASK --es task_name \"Kernel Flash Warning\"; export PATH=/sbin/.core/busybox:$PATH; sleep 4; unzip -p /data/data/com.termux/files/home/tmp/kernel.zip META-INF/com/google/android/update-binary | /system/bin/sh /proc/self/fd/0 unused 1 /data/data/com.termux/files/home/tmp/kernel.zip && /system/bin/svc power reboot'"
}

# Incremementally build the kernel, then flash it on the connected device via ADB
inc() {
    incbuild "$@" && ktest
}

# Incremementally build the kernel, then flash it on the device via SSH over LAN
sinc() {
    incbuild "$@" && sktest
}

# Incremementally build the kernel, then flash it on the device via SSH over VPN
vsinc() {
    incbuild "$@" && vsktest
}

# Incremementally build the kernel, push the ZIP, and flash it on the device via SSH over LAN
psinc() {
    dbuild "$@" && fn="builds/ProtonKernel-pixel3-test$(cat "$kroot/out/.version").zip" && scp "$fn" phone:/sdcard && sktest "$fn"
}

# Incremementally build the kernel, push the ZIP, and flash it on the device via SSH over VPN
pvsinc() {
    dbuild "$@" && fn="builds/ProtonKernel-pixel3-test$(cat "$kroot/out/.version").zip" && scp "$fn" vphone:/sdcard && vsktest "$fn"
}

# Show differences between the committed defconfig and current config
dc() {
    diff arch/arm64/configs/king_defconfig "$kroot/out/.config"
}

# Update the defconfig in the git tree
cpc() {
    # Don't use savedefconfig for readability and diffability
    cp "$kroot/out/.config" arch/arm64/configs/b1c1_defconfig
}

# Reset the current config to the committed defconfig
mc() {
    kmake king_defconfig
}

# Open an interactive config editor
cf() {
    kmake nconfig
}

# Edit the raw text config
ec() {
    ${EDITOR:-vim} "$kroot/out/.config"
}

# Get a sorted list of the side of various objects in the kernel
osize() {
    find "$kroot/out" -type f -name '*.o' ! -name 'built-in.o' ! -name 'vmlinux.o' \
    	-exec du -h --apparent-size {} + | sort -r -h | head -n "${1:-75}" | \
	perl -pe 's/([\d.]+[A-Z]?).+\/out\/(.+)\.o/$1\t$2.c/g'
}

# Update the subtrees in the kernel repo
utree() {
    git subtree pull --prefix techpack/audio msm-extra $1 # Techpack ASoC audio drivers
    git subtree pull --prefix drivers/staging/qcacld-3.0 qcacld-3.0 $1 # QCA CLD 3.0 Wi-Fi drivers
    git subtree pull --prefix drivers/staging/qca-wifi-host-cmn qca-wfi-host-cmn $1 # QCA Wi-Fi common files
    git subtree pull --prefix drivers/staging/fw-api wlan-fw-api $1 # QCA Wi-Fi firmware API
}

# Create a link to a commit on GitHub
glink() {
    echo "https://github.com/kdrag0n/proton_bluecross/commit/$1"
}

# Retrieve the kernel version from a flashable zip package
zver()
{
    unzip -p "$1" Image.lz4-dtb | lz4 -dc | strings | grep "Linux version 4"
=======

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
kernel_name="ProtonKernel"

# Defconfig name
defconfig="vendor/kirin_defconfig"

# Target architecture
arch="arm64"

# Base kernel compile flags (extended by compiler setup script)
kmake_flags=(
	-j"${jobs:-6}"
	ARCH="$arch"
	O="out"
)

# Target device name to use in flashable package names
device_name="zenfone6"

# Target device's SSH hostname (on LAN)
lan_ssh_host="zenfone6"

# Target device's SSH hostname (on VPN)
vpn_ssh_host="vzenfone6"


#### BASE ####

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
	"$1" --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//'
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
	local fn="${1:-kernel.zip}"

	# Populate fields based on build type (stable release or test build)
	if [[ $RELEASE_VER -gt 0 ]]; then
		local ver_prefix="v"
		local build_type="stable"
		local version="v$RELEASE_VER"
	else
		local ver_prefix="test"
		local build_type="test"
		local version="$(buildnum)"
	fi

	# Copy kernel image
	cp "$kroot/out/arch/$arch/boot/Image.gz" "$kroot/flasher/"

	# Copy device tree blob
	rm -fr "$kroot/flasher/dtbs"
	mkdir "$kroot/flasher/dtbs"
	cp "$kroot/out/arch/$arch/boot/dts/qcom/sm8150-v2.dtb" "$kroot/flasher/dtbs/"

	# Generate version banner to be shown during flash
	echo "  • Installing $build_type build $version" >| "$kroot/flasher/version"
	echo "  • Built on $(date "+%a %b %d, %Y")" >> "$kroot/flasher/version"

	# Ensure that the directory containing $fn exists but $fn doesn't
	mkdir -p "$(dirname "$fn")"
	rm -f "$fn"

	# Create ZIP
	echo "  ZIP     $fn"
	pushd "$kroot/flasher" > /dev/null
	zip -qr9 "$OLDPWD/$fn" .
	popd > /dev/null
}

# Create a test package of the current kernel image
function dzip() {
	mkzip "builds/$kernel_name-$device_name-test$(buildnum).zip"
}

# Build an incremental release package with the specified version
function rel() {
	# Take the first argument as version and pass the rest to make
	local ver="$1"
	shift

	# Compile kernel
	kmake "$@" && \

	# Create release package
	RELEASE_VER="$ver" mkzip "builds/$kernel_name-$device_name-v$ver.zip"
}

# Build a clean release package
function crel() {
	kmake clean && rel "$@"
}


#### BUILD & PACKAGE HELPERS ####

# Build a clean working-copy package
function cleanbuild() {
	kmake clean && kmake "$@" && mkzip
}

# Build an incremental working-copy package
function incbuild() {
	kmake "$@" && mkzip
}

# Build an incremental test package
function dbuild() {
	kmake "$@" && dzip
}


#### INSTALLATION ####

# Flash the given kernel package (defaults to latest) on the device via ADB
function ktest() {
	local fn="${1:-kernel.zip}"
	local target_fn="${2:-/data/local/tmp/$(basename "$fn")}"
	local backslash='\'

	# Wait for device to show up on ADB
	adb wait-for-any

	# Check if device is in Android or recovery
	if adb shell pgrep gatekeeperd > /dev/null; then
		# Device is in Android

		# Push package
		msg "Pushing kernel package..."
		adb push "$fn" "$target_fn" && \

		# Execute flasher script
		msg "Executing flasher on device..."
		cat <<-END | adb shell su -c sh -
		export PATH="/sbin/.core/busybox:\$PATH"

		unzip -p "$target_fn" META-INF/com/google/android/update-binary | $backslash
		/system/bin/sh /proc/self/fd/0 "" "" "$target_fn" && $backslash
		{ /system/bin/svc power reboot || reboot; }
		END
	else
		# Device is in recovery (assuming TWRP)

		# Push package
		msg "Pushing kernel package..."
		adb push "$fn" /tmp/kernel.zip && \

		# Tell TWRP to flash it and reboot afterwards
		msg "Executing flasher on device..."
		adb shell "twrp install /tmp/kernel.zip && reboot"
	fi
}

# Flash the given kernel package (default: latest) on the device via SSH to the given hostname (default: LAN)
function sktest() {
	local fn="${1:-kernel.zip}"
	local hostname="${2:-$lan_ssh_host}"
	local target_fn="${3:-$(basename "$fn")}"
	local backslash='\'

	# Push package
	msg "Pushing kernel package..."
	scp "$fn" "$hostname:$target_fn" && \

	# Execute flasher script
	msg "Executing flasher on device..." && \
	cat <<-END | ssh "$hostname" su -c sh -
	export PATH="/sbin/.core/busybox:\$PATH"
	am broadcast -a net.dinglisch.android.tasker.ACTION_TASK --es task_name "Kernel Flash Warning" &

	unzip -p "$target_fn" META-INF/com/google/android/update-binary | $backslash
	/system/bin/sh /proc/self/fd/0 "" "" "\$(readlink -f "$target_fn")" && $backslash
	{ { /system/bin/svc power reboot || reboot; } & exit; }
	END
}

# Flash the given kernel package (default: latest) on the device via SSH over VPN
function vsktest() {
	sktest "$1" "$vpn_ssh_host" "$2"
}


#### BUILD & FLASH HELPERS ####

# Build & flash an incremental working-copy kernel on the device via ADB
function inc() {
	incbuild "$@" && ktest
}

# Build & flash an incremental test kernel on the device via ADB and keep a copy
# of the package in /sdcard
function pinc() {
	dbuild "$@" && \
	local fn="builds/$kernel_name-$device_name-test$(buildnum).zip" && \
	ktest "$fn" "/sdcard/$(basename "$fn")"
}

# Build & flash an incremental working-copy kernel on the device via SSH over LAN
function sinc() {
	incbuild "$@" && sktest
}

# Build & flash an incremental working-copy kernel on the device via SSH over VPN
function vsinc() {
	incbuild "$@" && vsktest
}

# Build & flash an incremental test kernel on the device via SSH over LAN and
# keep a copy of the package in /sdcard
function psinc() {
	dbuild "$@" && \
	local fn="builds/$kernel_name-$device_name-test$(buildnum).zip" && \
	sktest "$fn" "" "/sdcard/$(basename "$fn")"
}

# Build & flash an incremental test kernel on the device via SSH over VPN and
# keep a copy of the package in /sdcard
function pvsinc() {
	dbuild "$@" && \
	local fn="builds/$kernel_name-$device_name-test$(buildnum).zip" && \
	vsktest "$fn" "/sdcard/$(basename "$fn")"
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


#### MISCELLANEOUS ####

# Get a sorted list of the side of various objects in the kernel
function osize() {
	find "$kroot/out" -type f -name '*.o' ! -name 'built-in.o' ! -name 'vmlinux.o' \
	-exec du -h --apparent-size {} + | sort -r -h | head -n "${1:-75}" | \
	perl -pe 's/([\d.]+[A-Z]?).+\/out\/(.+)\.o/$1\t$2.c/g'
}

# Create a link to a commit on GitHub
function glink() {
	echo "https://github.com/kdrag0n/proton_$device_name/commit/$1"
>>>>>>> 7e8db0a7835c... Import kernel build and helper scripts
}
