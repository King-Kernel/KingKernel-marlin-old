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

#functions
keytest() {
  ui_print "** Vol Key Test **"
  ui_print "** Press Vol UP **"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

set_bindir(){
    bindir=/system/bin
    xbindir=/system/xbin

    # Check for existence of /system/xbin directory.
    if [ -d /system/xbin ]; then
        # Use /system/xbin.
        cp $bin/sqlite3 $xbindir
        ui_print "  • Installed sqlite to $xbindir"
    else
        #use /system/bin instead of /system/xbin
        cp $bin/sqlite3 $bindir
        ui_print "  • Installed sqlite to $bindir"
    fi
}


chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "**  Vol key not detected **"
    abort "** Use name change method in TWRP **"
  fi
}

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$bin/keycheck
chmod 755 $KEYCHECK

#Change the custom ramdisk to the device hardware name
mv $TMPDIR/overlay/init.king.rc $TMPDIR/overlay/init.$(getprop ro.hardware).rc

#Sqlite keycheck logic
mount -o rw,remount -t auto /system >/dev/null

ui_print " "
if keytest; then
    FUNCTION=chooseport
else
    FUNCTION=chooseportold
    ui_print "** Volume button programming **"
    ui_print " "
    ui_print "** Press Vol UP again **"
    $FUNCTION "UP"
    ui_print "**  Press Vol DOWN **"
    $FUNCTION "DOWN"
fi
ui_print "There are Zipalign and SQlite tweaks in KingKernel"
ui_print "These can enhance battery life and make the device run smoother"
ui_print "However, apps have a possibility to stop working with sqlite tweaks"
ui_print "Please indicate whether you want them"
ui_print " "
ui_print "   Vol(+) = Yes"
ui_print "   Vol(-) = No"
ui_print " "
if $FUNCTION; then
    ui_print " Cool! Installing Sqlite tweaks... "
    ui_print " "
    set_bindir
    ui_print " "
else
    ui_print " Skipping Sqlite Tweaks..."
    #Remove if there's an old installation of sqlite3 and remove script from overlay
    rm -rf /system/xbin/sqlite3
    rm -rf $TMPDIR/overlay/init.Zipalign_sqlite.sh
    ui_print " "
fi;

#Clear any old ramdisk files
rm -fr $ramdisk/overlay
if [ -d $ramdisk/.backup ]; then
  ui_print "  • Patching ramdisk"
  patch_cmdline "skip_override" "skip_override"

  mv $TMPDIR/overlay $ramdisk
  # set permissions/ownership for included ramdisk files
  chmod -R 750 $ramdisk/*;
  chown -R root:root $ramdisk/*;
  
else
  patch_cmdline "skip_override" ""
  ui_print '  ! Magisk is not installed; some tweaks will be missing'
fi

mountpoint -q /data && {

  # Install checker script to service.d (checks to uninstall sqlite binary each boot)
  mkdir -p /data/adb/service.d
  cp $TMPDIR/checker.sh /data/adb/service.d
  chmod +x /data/adb/service.d/checker.sh

} || ui_print '  ! Data is not mounted; some tweaks will be missing'

# end ramdisk changes

write_boot;

## end install

