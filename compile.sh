make O=out ARCH=arm64 king_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC='/home/kingbri1/toolchains/clang-8.x/bin/clang' CLANG_TRIPLE=aarch64-linux-gnu CROSS_COMPILE_ARM32='/home/kingbri1/x-tools/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi-' CROSS_COMPILE='/home/kingbri1/x-tools/aarch64-unknown-linux-gnu/bin/aarch64-unknown-linux-gnu-'
