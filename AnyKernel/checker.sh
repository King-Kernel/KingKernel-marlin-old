#!/system/bin/sh

#logic created by kdrag0n, use by kingbri
#A simple script to check if KingKernel is installed and if it isn't, removes appropriate files
#Script removes itself afterwards once process is completed

#
# Cleanup
#

# Check if KingKernel is no longer installed
if ! grep -q KingKernel /proc/version; then
	# remove sqlite binary
	rm -rf /system/xbin/sqlite3	
	
	# Suicide the script
	rm -f /data/adb/service.d/checker.sh

	# Abort and do not apply anything
	exit 0
fi;

