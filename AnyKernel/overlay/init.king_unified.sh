#!/system/bin/sh

# (c) KingKernel kernel changes on performance intent

#make logs folder
mkdir /storage/emulated/0/logs
LOG_FILE=/storage/emulated/0/logs/Proflog

prof="$1"

if [ "$prof" == "battery" ]; then 
	#Default I/o sched bfq
	echo "bfq" > /sys/block/sda/queue/scheduler
	echo "bfq" > /sys/block/sdb/queue/scheduler
	echo "bfq" > /sys/block/sdc/queue/scheduler
	echo "bfq" > /sys/block/sdd/queue/scheduler
	echo "bfq" > /sys/block/sde/queue/scheduler
	echo "bfq" > /sys/block/sdf/queue/scheduler
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Battery executed" | tee -a $LOG_FILE;
elif [ "$prof" == "balanced" ]; then 
	#Default I/o sched bfq
	echo "maple" > /sys/block/sda/queue/scheduler
	echo "maple" > /sys/block/sdb/queue/scheduler
	echo "maple" > /sys/block/sdc/queue/scheduler
	echo "maple" > /sys/block/sdd/queue/scheduler
	echo "maple" > /sys/block/sde/queue/scheduler
	echo "maple" > /sys/block/sdf/queue/scheduler
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Balanced executed" | tee -a $LOG_FILE;
elif [ "$prof" == "performance" ]; then 
	#Default I/o sched bfq
	echo "deadline" > /sys/block/sda/queue/scheduler
	echo "deadline" > /sys/block/sdb/queue/scheduler
	echo "deadline" > /sys/block/sdc/queue/scheduler
	echo "deadline" > /sys/block/sdd/queue/scheduler
	echo "deadline" > /sys/block/sde/queue/scheduler
	echo "deadline" > /sys/block/sdf/queue/scheduler
	echo "---------------------------------------------" | tee -a $LOG_FILE;
        echo "Performance executed" | tee -a $LOG_FILE;
fi;
