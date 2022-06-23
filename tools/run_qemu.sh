#!/bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

if [ $# -ne 2 ]
then
    exit 1
fi

qemu_arch=$1
qemu_graphic=$2
bin_dir=`readlink -f "$script_path"/../bin`

qemu_args=()
qemu_args+=(-enable-kvm)
qemu_args+=(-kernel "$bin_dir"/vmlinuz)
qemu_args+=(-initrd "$bin_dir"/initramfs.img)
qemu_args+=(-append 'console=ttyS0')

qemu_network_args=$(printf \
    'net=%s,dhcpstart=%s,hostfwd=%s' \
    '192.168.5.0/24' \
    '192.168.5.11' \
    'udp:127.0.0.1:5069-192.168.5.5:69')

if [ "$qemu_arch" == 'x86_64' ]
then
    qemu_prog=qemu-system-x86_64
    qemu_args+=(-machine q35)
    qemu_args+=(-cpu host -smp 4)
    qemu_args+=(-m 256M)
    qemu_args+=(-nic user,model=e1000,$qemu_network_args)
else
    exit 1
fi

if [ "$qemu_graphic" == "nographic" ]
then
    qemu_args+=(-nographic)
fi

"$qemu_prog" ${qemu_args[@]}
