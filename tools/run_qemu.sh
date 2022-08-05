#!/bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

if [ $# -ne 2 ]
then
    exit 1
fi

vm_name=$1
qemu_graphic=$2
bin_dir=`readlink -f "$script_path"/../bin`

qemu_prog=qemu-system-x86_64
qemu_args=()
qemu_args+=(-enable-kvm)
qemu_args+=(-kernel "$bin_dir"/vmlinuz)
qemu_args+=(-initrd "$bin_dir"/initramfs."$vm_name".img)
qemu_args+=(-append 'tsc=nowatchdog console=ttyS0')
qemu_args+=(-machine q35)
qemu_args+=(-cpu host -smp 4)
qemu_args+=(-m 256M)

if [ "$vm_name" == 'main' ]
then
    nic_args=$(printf \
        'user,model=e1000,net=%s,dhcpstart=%s,hostfwd=%s' \
        '192.168.5.0/24' \
        '192.168.5.11' \
        'udp:127.0.0.1:5069-192.168.5.11:69')
    qemu_args+=(-nic "$nic_args")
elif [ "$vm_name" == 'router' ]
then
    nic_args=$(printf \
        'user,model=e1000,net=%s,dhcpstart=%s' \
        '192.168.6.0/24' \
        '192.168.6.11')
    qemu_args+=(-nic "$nic_args")
    nic_args=$(printf \
        'tap,model=e1000,ifname=%s,script=no,downscript=no,mac=00:11:22:33:44:55' \
        'qemu0')
    qemu_args+=(-nic "$nic_args")
elif [ "$vm_name" == 'local' ]
then
    nic_args=$(printf \
        'tap,model=e1000,ifname=%s,script=no,downscript=no,mac=00:11:22:33:44:56' \
        'qemu1')
    qemu_args+=(-nic "$nic_args")
else
    exit 1
fi

if [ "$qemu_graphic" == "nographic" ]
then
    qemu_args+=(-nographic)
fi

"$qemu_prog" "${qemu_args[@]}"
