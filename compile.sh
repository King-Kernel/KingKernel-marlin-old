make O=out ARCH=arm64 king_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC='/home/kingbri1/toolchains/clang-9.0/bin/clang' CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE_ARM32='/home/kingbri1/toolchains/arm-gcc/bin/arm-buildroot-linux-gnueabi-' CROSS_COMPILE='/home/kingbri1/toolchains/aarch64-gcc/bin/aarch64-buildroot-linux-gnu-'
