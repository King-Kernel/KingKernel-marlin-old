#!/usr/bin/env/bash
# Drone CI kernel build script

# Export User and Hostname
export KBUILD_BUILD_USER=kingbri
export KBUILD_BUILD_HOST=KingKernel

# Source setup script
source setup.sh

# initalize config
mc

# Start kernel build
time kmake | tee "$DRONE_WORKSPACE/compile.log"

# Copy the image to AnyKernel3
cp out/arch/arm64/boot/Image.lz4-dtb AnyKernel3

# Make a zip file from AnyKernel3
ZIPNAME="KingKernel-ci-v$DRONE_BUILD_NUMBER.zip"
cd AnyKernel3
zip -r ${ZIPNAME} . -x .gitignore

curl -s -X POST https://api.telegram.org/bot${BOT_API_KEY}/sendMessage -d text="Build compiled successfully" -d chat_id=${CI_CHANNEL_ID} -d parse_mode=HTML

curl -F chat_id="${CI_CHANNEL_ID}" -F document=@"$(pwd)/${ZIPNAME}" https://api.telegram.org/bot${BOT_API_KEY}/sendDocument

