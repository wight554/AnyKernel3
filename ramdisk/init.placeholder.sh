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

{

sleep 10

# cpu
chmod 0664 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
chmod 0664 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "schedutil"
write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us 500
write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us 20000
write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/iowait_boost_enable 1
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 300000

write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor "schedutil"
write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us 500
write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us 20000
write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/iowait_boost_enable 1
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 300000

sleep 20

}&
