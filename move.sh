rm -r /media/insomniac12/MATE/KingKernel-AnyKernel2/dtbs/*
echo "removed dtbs"
cp /home/insomniac12/KingKernel-private/out/arch/arm64/boot/dts/htc/* /media/insomniac12/MATE/KingKernel-AnyKernel2/dtbs/
echo "Added new dtbs"
sudo chown insomniac12 /media/insomniac12/MATE/KingKernel-AnyKernel2/dtbs/*
rm -r /media/insomniac12/MATE/KingKernel-AnyKernel2/dtbs/modules.order
sudo chown insomniac12 /media/insomniac12/MATE/KingKernel-AnyKernel2/kernel
rm -r /media/insomniac12/MATE/KingKernel-AnyKernel2/kernel/*
echo "Removed old kernel file"
sudo chown insomniac12 /media/insomniac12/MATE/KingKernel-AnyKernel2/kernel
cp /home/insomniac12/KingKernel-private/out/arch/arm64/boot/Image.lz4 /media/insomniac12/MATE/KingKernel-AnyKernel2/kernel
echo "Added new kernel file"
sudo chown insomniac12 /media/insomniac12/MATE/KingKernel-AnyKernel2/kernel/Image.lz4
echo "Done"
