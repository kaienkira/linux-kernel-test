#!/bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

if [ $# -ne 1 ]
then
    exit 1
fi

busybox_src_dir=`readlink -f "$1"`
bin_dir=`readlink -f "$script_path"/../bin`
settings_dir=`readlink -f "$script_path"/../settings`
initramfs_tmp_dir=$bin_dir/initramfs.tmp

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
mkdir {etc,opt,proc,sys}
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
find . -print0 | cpio --null -o --format=newc -R +0:+0 |
    gzip > "$bin_dir"/initramfs.img
if [ $? -ne 0 ]; then exit 1; fi

exit 0
