#!/system/bin/sh

# (c) KingKernel kernel changes on late

#make logs folder
mkdir /storage/emulated/0/logs
LOG_FILE=/storage/emulated/0/logs/KingKernellog

echo " " > $LOG_FILE;
echo "Late tweaks started" | tee -a $LOG_FILE;

#Immediate executions for boot

#Disable core_control and enable cpu3 if it's offline
echo "0" > /sys/module/msm_thermal/core_control/enabled
echo "1" > /sys/devices/system/cpu/cpu3/online

#Schedutil gov tweaks

echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/iowait_boost_enable

#cpu1
echo "0" > /sys/devices/system/cpu/cpu1/cpufreq/schedutil/iowait_boost_enable

#cpu2
echo "0" > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/iowait_boost_enable

#cpu3
echo "0" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/iowait_boost_enable

#Default I/o sched cfq
echo "cfq" > /sys/block/sda/queue/scheduler
echo "cfq" > /sys/block/sdb/queue/scheduler
echo "cfq" > /sys/block/sdc/queue/scheduler
echo "cfq" > /sys/block/sdd/queue/scheduler
echo "cfq" > /sys/block/sde/queue/scheduler
echo "cfq" > /sys/block/sdf/queue/scheduler

#Change swappiness
echo "20" > /proc/sys/vm/swappiness

# Fixup LEDs
echo "170" > /sys/class/leds/blue/max_brightness
echo "170" > /sys/class/leds/green/max_brightness
echo "170" > /sys/class/leds/lcd-backlight/max_brightness
echo "170" > /sys/class/leds/led:switch/max_brightness
echo "170" > /sys/class/leds/red/max_brightness

# Force enable fast charge
echo "1" > /sys/kernel/fast_charge/force_fast_charge

sleep 25;
# Script log file location

export TZ=$(getprop persist.sys.timezone);
echo $(date) | tee -a $LOG_FILE
if [ $? -eq 0 ]
then
  echo "---------------------------------------------" | tee -a $LOG_FILE;
  echo "KingKernel late script successful!" | tee -a $LOG_FILE;
  exit 0
else
  echo "---------------------------------------------" | tee -a $LOG_FILE;
  echo "KingKernel late script failed. Please check your installation..." | tee -a $LOG_FILE;
  exit 1
fi
  
# Wait..
# Done!
#
