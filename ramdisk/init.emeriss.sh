#!/vendor/bin/sh
MemTotalStr=`cat /proc/meminfo | grep MemTotal`
MemTotal=${MemTotalStr:16:8}

# Read adj series and set adj threshold for PPR and ALMK.
# This is required since adj values change from framework to framework.
adj_series=`cat /sys/module/lowmemorykiller/parameters/adj`
adj_1="${adj_series#*,}"
set_almk_ppr_adj="${adj_1%%,*}"

# PPR and ALMK should not act on HOME adj and below.
# Normalized ADJ for HOME is 6. Hence multiply by 6
# ADJ score represented as INT in LMK params, actual score can be in decimal
# Hence add 6 considering a worst case of 0.9 conversion to INT (0.9*6).
set_almk_ppr_adj=$(((set_almk_ppr_adj * 6) + 6))
echo $set_almk_ppr_adj > /sys/module/lowmemorykiller/parameters/adj_max_shift
echo $set_almk_ppr_adj > /sys/module/process_reclaim/parameters/min_score_adj

# Dynamic ZRAM
configure_zram()
{
if [ -e /sys/block/zram0/disksize ] ; then
  swapoff /dev/block/zram0  > /dev/null 2>&1
  echo 1 > /sys/block/zram0/reset
  echo $SWAPSIZE > /sys/block/zram0/disksize
  mkswap /dev/block/zram0
  swapon /dev/block/zram0  > /dev/null 2>&1
fi
}

#Set Low memory killer minfree parameters
# 64 bit up to 2GB with use 14K, and above 2GB will use 18K
#
# Set ALMK parameters (usually above the highest minfree values)
# 64 bit will have 81K
#
# Also dynamically set zram size (512MB for 3GB RAM and 1024MB for 2GB RAM)
if [ $MemTotal -gt 2097152 ]; then
    echo "18432,23040,27648,32256,55296,80640" > /sys/module/lowmemorykiller/parameters/minfree
    SWAPSIZE=536870912
else
    echo "14746,18432,22118,25805,40000,55000" > /sys/module/lowmemorykiller/parameters/minfree
    SWAPSIZE=1073741824
fi

# Run ZRAM configure
configure_zram
