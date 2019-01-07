make O=out ARCH=arm64 king_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC='/toolchains/clang/bin/clang' CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE_ARM32='/toolchains/arm-gcc/bin/arm-buildroot-linux-gnueabi-' CROSS_COMPILE='/toolchains/aarch64-gcc/bin/aarch64-buildroot-linux-gnu-'
