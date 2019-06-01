#!/system/bin/sh

function write() {
    echo -n $2 > $1
}

{
    sleep 10

    # end boot time fs tune
    write /sys/block/sda/queue/read_ahead_kb 128
    write /sys/block/sda/queue/nr_requests 128
    write /sys/block/sda/queue/iostats 1
    write /sys/block/sda/queue/scheduler cfq
    write /sys/block/sde/queue/read_ahead_kb 128
    write /sys/block/sde/queue/nr_requests 128
    write /sys/block/sde/queue/iostats 1
    write /sys/block/sde/queue/scheduler cfq

    # configure governor settings
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "schedutil"
    write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us 20000
    write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us 500

    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor "schedutil"
    write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us 20000
    write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us 500

    write /proc/sys/vm/page-cluster 0
    write /proc/sys/vm/swappiness 100

    # set interaction lock idle time
    write /sys/devices/virtual/graphics/fb0/idle_time 100

    sleep 20
}&
