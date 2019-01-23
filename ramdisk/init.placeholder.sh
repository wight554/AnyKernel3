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
    write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/iowait_boost_enable 1
    write /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us 500

    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor "schedutil"
    write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us 20000
    write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/iowait_boost_enable 1
    write /sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us 500

    # zram setup
    swapoff /dev/block/zram0
    write /sys/block/zram0/reset 1
    write /sys/block/zram0/comp_algorithm lz4
    write /sys/block/zram0/disksize 1073741824
    write /sys/block/zram0/max_comp_streams 8
    write /proc/sys/vm/page-cluster 0
    write /proc/sys/vm/swappiness 100
    mkswap /dev/block/zram0
    swapon /dev/block/zram0

    sleep 20
}&
