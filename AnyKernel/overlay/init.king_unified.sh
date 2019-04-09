#!/system/bin/sh

# (c) KingKernel kernel changes on performance intent

#miscellaneous functions
swappiness() { echo "$1" > /proc/sys/vm/swappiness; }
down_rate_limit () {
	echo "$1" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us;
	echo "$1" > /sys/devices/system/cpu/cpu1/cpufreq/schedutil/down_rate_limit_us;
	echo "$1" > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/down_rate_limit_us;
	echo "$1" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/down_rate_limit_us;
}
up_rate_limit () {
	echo "$1" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us;
	echo "$1" > /sys/devices/system/cpu/cpu1/cpufreq/schedutil/up_rate_limit_us;
	echo "$1" > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/up_rate_limit_us;
	echo "$1" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/up_rate_limit_us;	
}
stune_boost() { echo "$1" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost; }
cib_duration() { echo "$1" > /sys/module/cpu_input_boost/parameters/input_boost_duration; }
cib_boost_lp() { echo "$1" > /sys/module/cpu_input_boost/parameters/input_boost_freq_lp; }
cib_boost_hp() { echo "$1" > /sys/module/cpu_input_boost/parameters/input_boost_freq_hp; }
frame_boost_timeout () { echo "$1" > /sys/module/cpu_input_boost/parameters/frame_boost_timeout; }

#make logs folder
mkdir /storage/emulated/0/logs
LOG_FILE=/storage/emulated/0/logs/Proflog

prof="$1"

case "$prof" in
  'battery')
	swappiness 20
	down_rate_limit 1000
	up_rate_limit 500
	stune_boost 5
	cib_duration 30
	cib_boost_lp 307200
	cib_boost_hp 307200
	frame_boost_timeout 1750
	echo "---------------------------------------------" | tee -a $LOG_FILE;
    echo "Battery executed" | tee -a $LOG_FILE;
	;;
  'balanced')
	swappiness 20
	down_rate_limit 500
	up_rate_limit 500
	stune_boost 10
	cib_duration 64
	cib_boost_lp 537600
	cib_boost_hp 460800
	frame_boost_timeout 2700
	echo "---------------------------------------------" | tee -a $LOG_FILE;
    echo "Balanced executed" | tee -a $LOG_FILE;
	;;
  'performance')
	swappiness 100
	down_rate_limit 500
	up_rate_limit 1000
	stune_boost 50
	cib_duration 125
	cib_boost_lp 844200
	cib_boost_hp 614000
	frame_boost_timeout 13000
	echo "---------------------------------------------" | tee -a $LOG_FILE;
    echo "Performance executed" | tee -a $LOG_FILE;
	;;
  *)
	echo "Valid actions: [profiles] battery, balanced, performance"
	exit 1
esac;
