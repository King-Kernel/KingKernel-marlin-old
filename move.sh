rm -r ../AnyKernel2-marlin/dtbs/*
echo "removed dtbs"
cp out/arch/arm64/boot/dts/htc/* ../AnyKernel2-marlin/dtbs/
echo "Added new dtbs"
rm -r ../AnyKernel2-marlin/dtbs/modules.order
rm -r ../AnyKernel2-marlin/kernel/*
echo "Removed old kernel file"
cp out/arch/arm64/boot/Image.lz4 ../AnyKernel2-marlin/kernel
echo "Added new kernel file"
echo "Done"
