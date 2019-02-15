# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=KingKernel by kingbri@KingKernel and sweezie@KingKernel
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=marlin
device.name2=sailfish
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. $TMPDIR/tools/ak2-core.sh;

## AnyKernel install
ui_print "  • Unpacking image"
dump_boot;

# begin ramdisk changes

if [ "$(getprop ro.product.device)" == "marlin" ]; then
  rm -r $TMPDIR/overlay/init.sailfish.rc
fi

if [ "$(getprop ro.product.device)" == "sailfish" ]; then
  rm -r $TMPDIR/overlay/init.marlin.rc
fi

rm -fr $ramdisk/overlay

if [ -d $ramdisk/.backup ]; then
  ui_print "  • Patching ramdisk"
  patch_cmdline "skip_override" "skip_override"

  mv $TMPDIR/overlay $ramdisk
  cp /system_root/init.rc $ramdisk/overlay
  # set permissions/ownership for included ramdisk files
  chmod -R 750 $ramdisk/*;
  chown -R root:root $ramdisk/*;
  
else
  patch_cmdline "skip_override" ""
  ui_print '  ! Magisk is not installed; some tweaks will be missing'
fi

#Copy sqlite bin 
mount -o rw,remount -t auto /system >/dev/null
bindir=/system/bin
xbindir=/system/xbin

# Check for existence of /system/xbin directory.
if [ -d /system/xbin ]; then
    # Use /system/xbin.
    cp $bin/sqlite3 $xbindir
else
    #use /system/bin instead of /system/xbin
    cp $bin/sqlite3 $bindir
fi
ui_print "  • Installed sqlite to $xbindir"

mountpoint -q /data && {

  # Install checker script to service.d (checks to uninstall sqlite binary each boot)
  mkdir -p /data/adb/service.d
  cp $TMPDIR/checker.sh /data/adb/service.d
  chmod +x /data/adb/service.d/checker.sh

} || ui_print '  ! Data is not mounted; some tweaks will be missing'

# end ramdisk changes

write_boot;

## end install

