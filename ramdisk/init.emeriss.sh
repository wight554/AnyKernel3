#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

# macro to write pids to system-background cpuset
function writepid_sbg() {
    until [ ! "$1" ]; do
        echo -n $1 > /dev/cpuset/system-background/tasks;
        shift;
    done;
}

function writepid_top_app() {
    until [ ! "$1" ]; do
        echo -n $1 > /dev/cpuset/top-app/tasks;
        shift;
    done;
}
################################################################################

################################################################################
# Dynamic ZRAM (512MB for 3GB RAM and 1024MB for 2GB RAM)
MemTotalStr=`cat /proc/meminfo | grep MemTotal`
MemTotal=${MemTotalStr:16:8}

configure_zram(SWAPSIZE)
{
if [ -e /sys/block/zram0/disksize ] ; then
  swapoff /dev/block/zram0  > /dev/null 2>&1
  echo 1 > /sys/block/zram0/reset
  echo $SWAPSIZE > /sys/block/zram0/disksize
  mkswap /dev/block/zram0
  swapon /dev/block/zram0  > /dev/null 2>&1
fi
}

if [ $MemTotal -gt 2097152 ]; then
    configure_zram(536870912)
else
    configure_zram(1073741824)
fi
################################################################################

{

sleep 10

# cpu
chmod 0664 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
chmod 0664 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
chmod 0664 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
chmod 0664 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
chmod 0664 /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
chmod 0664 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

# configure governor settings for little cluster
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 691200
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 1401600
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay "0 691200:20000 806400:24000 1190400:38000"
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/fastlane 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/fastlane_threshold 50
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 99
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_lowspeed_load 10
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 806400
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy 1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "60 400000:62 691200:70 806400:76 1017600:81 1190400:86 1305600:89 1382400:91 1401600:94"
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 45000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/powersave_bias 1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 35000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate_screenoff 50000

# configure governor settings for big cluster
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 883200
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 1804800
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay "30000 1056000:10000 1305600:30000"
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/fastlane 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/fastlane_threshold 50
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load 99
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_lowspeed_load 10
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq 1056000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy 1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "83 883200:84 998400:85 1113600:84 1190400:86 1305600:85 1612800:83 1804800:95"
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 40000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/powersave_bias 1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate_screenoff 50000

# Input boost configuration
write /sys/module/cpu_boost/parameters/input_boost_freq "0:1190400"
write /sys/module/cpu_boost/parameters/input_boost_ms 400

# enable Audio High Performance Mode
write /sys/module/snd_soc_msm8x16_wcd/parameters/high_perf_mode 1

# Disable perfd
stop perfd

sleep 20

}&
