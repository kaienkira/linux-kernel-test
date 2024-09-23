# linux-kernel-test

```
pacman -S base-devel bc qemu-full curl rsync cpio python-setuptools parted

vi /etc/systemd/network/90-brqemu0.netdev
    [NetDev]
    Name=brqemu0
    Kind=bridge

vi /etc/systemd/network/91-qemu0.netdev
    [NetDev]
    Name=qemu0
    Kind=tap

    [Tap]
    User=
    Group=

vi /etc/systemd/network/91-qemu1.netdev
    [NetDev]
    Name=qemu1
    Kind=tap

    [Tap]
    User=
    Group=

vi /etc/systemd/network/92-brqemu.network
    [Match]
    Name=brqemu*

vi /etc/systemd/network/92-qemu.network
    [Match]
    Name=qemu*

    [Network]
    Bridge=brqemu0

```
