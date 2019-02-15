#!/system/bin/sh

# (c) KingKernel kernel changes on performance intent

#make logs folder
mkdir /storage/emulated/0/logs
LOG_FILE=/storage/emulated/0/logs/Proflog

prof="$1"

if [ "$prof" == "battery" ]; then 
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Battery executed" | tee -a $LOG_FILE;
elif [ "$prof" == "balanced" ]; then 
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Balanced executed" | tee -a $LOG_FILE;
elif [ "$prof" == "performance" ]; then 
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Performance executed" | tee -a $LOG_FILE;
fi;
