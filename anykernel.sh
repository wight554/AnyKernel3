# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=PlaceholderKernel by Wight554
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=chiron
supported.versions=8-9
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;
# begin ramdisk changes

# sepolicy
$bin/magiskpolicy --load sepolicy --save sepolicy \
"allow init rootfs file execute_no_trans" \
;

# Kill init's search for Treble split sepolicy if Magisk is not present
# This will force init to load the monolithic sepolicy at /
if [ ! -d .backup ]; then
    sed -i 's;selinux/plat_sepolicy.cil;selinux/plat_sepolicy.xxx;g' init;
fi;

# end ramdisk changes

write_boot;

## end install

