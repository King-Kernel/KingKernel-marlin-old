make O=out ARCH=arm64 king_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC='/media/insomniac12/MATE/dtc/out/8.0/bin/clang' CLANG_TRIPLE=aarch64-linux-gnu CROSS_COMPILE_ARM32='/home/insomniac12/arm-linux-gnueabi/bin/arm-linux-gnueabi-' CROSS_COMPILE='/home/insomniac12/aarch64-linux-gnu/bin/aarch64-linux-gnu-'
