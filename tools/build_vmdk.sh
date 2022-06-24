#!/bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

if [ $# -ne 2 ]
then
    exit 1
fi

busybox_src_dir=`readlink -f "$1"`
grub_src_dir=`readlink -f "$2"`
bin_dir=`readlink -f "$script_path"/../bin`
settings_dir=`readlink -f "$script_path"/../settings`
vmdk_file=$bin_dir/BRLinux.vmdk
image_file=$bin_dir/BRLinux.img
image_file_part1=$bin_dir/BRLinux.img.part1
initramfs_file=$bin_dir/BRLinux.initramfs.img
initramfs_tmp_dir=$bin_dir/BRLinux.initramfs.tmp

do_cleanup()
{
    rm -f "$image_file"
    rm -f "$image_file_part1"
    rm -f "$initramfs_file"
    rm -rf "$initramfs_tmp_dir"
}
trap do_cleanup EXIT

truncate -s 1MiB "$image_file"
if [ $? -ne 0 ]; then exit 1; fi
truncate -s 63MiB "$image_file_part1"
if [ $? -ne 0 ]; then exit 1; fi
mkfs.ext4 "$image_file_part1"
if [ $? -ne 0 ]; then exit 1; fi
cat "$image_file_part1" >> "$image_file"
if [ $? -ne 0 ]; then exit 1; fi

parted -s "$image_file" \
    mklabel msdos \
    mkpart primary ext4 1MiB 100% \
    set 1 boot on
if [ $? -ne 0 ]; then exit 1; fi

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
mkdir {boot,etc,opt,proc,sys}
if [ $? -ne 0 ]; then exit 1; fi
cp -r "$grub_src_dir"/build/_install/opt/grub opt
if [ $? -ne 0 ]; then exit 1; fi
cp "$bin_dir"/vmlinuz opt
if [ $? -ne 0 ]; then exit 1; fi
cp "$bin_dir"/initramfs.img opt
if [ $? -ne 0 ]; then exit 1; fi
echo \
'#!/bin/sh

mount -t proc none /proc
mount -t sysfs none /sys

mknod -m 666 /dev/null c 1 3
mknod -m 666 /dev/zero c 1 5
mknod -m 444 /dev/random c 1 8
mknod -m 444 /dev/urandom c 1 9
mknod -m 666 /dev/tty0 c 4 0
mknod -m 666 /dev/ttyS0 c 4 64
mknod -m 666 /dev/sda b 8 0
mknod -m 666 /dev/sda1 b 8 1

mount /dev/sda1 /boot
/opt/grub/sbin/grub-install /dev/sda
cp /opt/vmlinuz /boot
cp /opt/initramfs.img /boot
echo "
insmod part_msdos
insmod ext2
menuentry BRLinux {
    linux (hd0,msdos1)/vmlinuz
    initrd (hd0,msdos1)/initramfs.img
}
" > /boot/grub/grub.cfg

exec /sbin/init
' >init
if [ $? -ne 0 ]; then exit 1; fi
chmod +x init
if [ $? -ne 0 ]; then exit 1; fi
echo \
'::sysinit:/sbin/poweroff
' >etc/inittab
if [ $? -ne 0 ]; then exit 1; fi
find . -print0 | cpio --null -o --format=newc -R +0:+0 |
    gzip > "$initramfs_file"
if [ $? -ne 0 ]; then exit 1; fi

qemu-system-x86_64 \
    -enable-kvm \
    -nographic \
    -kernel "$bin_dir"/vmlinuz \
    -initrd "$initramfs_file" \
    -append 'tsc=nowatchdog console=ttyS0' \
    -machine q35 \
    -cpu host -smp 1 -m 128M \
    -drive driver=raw,file="$image_file"
if [ $? -ne 0 ]; then exit 1; fi

qemu-img convert -f raw -O vmdk "$image_file" "$vmdk_file"
if [ $? -ne 0 ]; then exit 1; fi

exit 0
