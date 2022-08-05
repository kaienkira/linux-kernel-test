#!/bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

if [ $# -ne 3 ]
then
    exit 1
fi

vm_name=$1
busybox_src_dir=`readlink -f "$2"`
iptables_src_dir=`readlink -f "$3"`
bin_dir=`readlink -f "$script_path"/../bin`
settings_dir=`readlink -f "$script_path"/../settings/vm_$vm_name`
initramfs_tmp_dir=$bin_dir/initramfs.$vm_name.tmp

do_cleanup()
{
    rm -rf "$initramfs_tmp_dir"
}
trap do_cleanup EXIT

rm -rf "$initramfs_tmp_dir"
if [ $? -ne 0 ]; then exit 1; fi
mkdir "$initramfs_tmp_dir"
if [ $? -ne 0 ]; then exit 1; fi

cp -r "$busybox_src_dir"/build/_install "$initramfs_tmp_dir"
if [ $? -ne 0 ]; then exit 1; fi

cd "$initramfs_tmp_dir"/_install
if [ $? -ne 0 ]; then exit 1; fi
rm -f linuxrc
if [ $? -ne 0 ]; then exit 1; fi
mkdir {etc,opt,proc,run,sys}
if [ $? -ne 0 ]; then exit 1; fi
mkdir etc/init.d
if [ $? -ne 0 ]; then exit 1; fi
cp "$settings_dir"/init init
if [ $? -ne 0 ]; then exit 1; fi
chmod +x init
if [ $? -ne 0 ]; then exit 1; fi
cp "$settings_dir"/inittab etc/inittab
if [ $? -ne 0 ]; then exit 1; fi
cp "$settings_dir"/resolv.conf etc/resolv.conf
if [ $? -ne 0 ]; then exit 1; fi
cp "$settings_dir"/rcS etc/init.d/rcS
if [ $? -ne 0 ]; then exit 1; fi
chmod +x etc/init.d/rcS
if [ $? -ne 0 ]; then exit 1; fi
cp "$busybox_src_dir"/examples/udhcp/simple.script etc/udhcpc.script
cp "$iptables_src_dir"/build/_install/sbin/* sbin/
if [ $? -ne 0 ]; then exit 1; fi

find . -print0 | cpio --null -o --format=newc -R +0:+0 |
    gzip > "$bin_dir"/initramfs."$vm_name".img
if [ $? -ne 0 ]; then exit 1; fi

exit 0
