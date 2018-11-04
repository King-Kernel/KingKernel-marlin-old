rm -r /home/kingbri1/AnyKernel2/dtbs/*
echo "removed dtbs"
cp /home/kingbri1/KingKernel-private/out/arch/arm64/boot/dts/htc/* /home/kingbri1/AnyKernel2/dtbs/
echo "Added new dtbs"
sudo chown kingbri1 /home/kingbri1/AnyKernel2/dtbs/*
rm -r /home/kingbri1/AnyKernel2/dtbs/modules.order
sudo chown kingbri1 /home/kingbri1/AnyKernel2/kernel
rm -r /home/kingbri1/AnyKernel2/kernel/*
echo "Removed old kernel file"
sudo chown kingbri1 /home/kingbri1/AnyKernel2/kernel
cp /home/kingbri1/KingKernel-private/out/arch/arm64/boot/Image.lz4 /home/kingbri1/AnyKernel2/kernel
echo "Added new kernel file"
sudo chown kingbri1 /home/kingbri1/AnyKernel2/kernel/Image.lz4
echo "Done"
