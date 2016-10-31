#!/system/bin/sh

# (c) KingKernel kernel changes on performance intent

#make logs folder
mkdir /storage/emulated/0/logs
LOG_FILE=/storage/emulated/0/logs/Proflog

prof="$1"

if [ "$prof" == "battery" ]; then 
	echo "20" > /proc/sys/vm/swappiness
	echo "1000" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
	echo "1000" > /sys/devices/system/cpu/cpu1/cpufreq/schedutil/down_rate_limit_us
	echo "1000" > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/down_rate_limit_us
	echo "1000" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/down_rate_limit_us
	echo "100" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/hispeed_load
	echo "10" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
	echo "30" > /sys/module/cpu_input_boost/parameters/input_boost_duration
	echo "307200" > /sys/module/cpu_input_boost/parameters/input_boost_freq_lp
	echo "307200" > /sys/module/cpu_input_boost/parameters/input_boost_freq_hp
	echo "1750" > /sys/module/cpu_input_boost/parameters/frame_boost_timeout
	echo "10" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Battery executed" | tee -a $LOG_FILE;
elif [ "$prof" == "balanced" ]; then 
	echo "20" > /proc/sys/vm/swappiness
	echo "500" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
	echo "500" > /sys/devices/system/cpu/cpu1/cpufreq/schedutil/down_rate_limit_us
	echo "500" > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/down_rate_limit_us
	echo "500" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/down_rate_limit_us
	echo "30" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/hispeed_load
	echo "20" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
	echo "64" > /sys/module/cpu_input_boost/parameters/input_boost_duration
	echo "537000" > /sys/module/cpu_input_boost/parameters/input_boost_freq_lp
	echo "460000" > /sys/module/cpu_input_boost/parameters/input_boost_freq_hp
	echo "2700" > /sys/module/cpu_input_boost/parameters/frame_boost_timeout
	echo "15" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Balanced executed" | tee -a $LOG_FILE;
elif [ "$prof" == "performance" ]; then 
	echo "100" > /proc/sys/vm/swappiness
	echo "300" > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
	echo "300" > /sys/devices/system/cpu/cpu1/cpufreq/schedutil/down_rate_limit_us
	echo "300" > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/down_rate_limit_us
	echo "300" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/down_rate_limit_us
	echo "15" > /sys/devices/system/cpu/cpu3/cpufreq/schedutil/hispeed_load
	echo "50" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
	echo "125" > /sys/module/cpu_input_boost/parameters/input_boost_duration
	echo "844200" > /sys/module/cpu_input_boost/parameters/input_boost_freq_lp
	echo "614000" > /sys/module/cpu_input_boost/parameters/input_boost_freq_hp
	echo "13000" > /sys/module/cpu_input_boost/parameters/frame_boost_timeout
	echo "50" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Performance executed" | tee -a $LOG_FILE;
fi;
