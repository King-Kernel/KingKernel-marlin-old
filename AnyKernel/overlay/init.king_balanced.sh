#!/system/bin/sh

# (c) KingKernel kernel changes on late

#make logs folder
mkdir /storage/emulated/0/logs
LOG_FILE=/storage/emulated/0/logs/Batterylog

#Default I/o sched bfq
echo "maple" > /sys/block/sda/queue/scheduler
echo "maple" > /sys/block/sdb/queue/scheduler
echo "maple" > /sys/block/sdc/queue/scheduler
echo "maple" > /sys/block/sdd/queue/scheduler
echo "maple" > /sys/block/sde/queue/scheduler
echo "maple" > /sys/block/sdf/queue/scheduler

# For debugging

export TZ=$(getprop persist.sys.timezone);
echo $(date) | tee -a $LOG_FILE
if [ $? -eq 0 ]
then
  echo "---------------------------------------------" | tee -a $LOG_FILE;
  echo "Balanced executed" | tee -a $LOG_FILE;
  exit 0
else
  echo "---------------------------------------------" | tee -a $LOG_FILE;
  echo "Balanced failed" | tee -a $LOG_FILE;
  exit 1
fi
  
# Wait..
# Done!
#
