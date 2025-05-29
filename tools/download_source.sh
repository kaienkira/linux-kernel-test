#!bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

src_dir=`readlink -f "$script_path"/../src`

cd "$src_dir"
if [ $? -ne 0 ]; then exit 1; fi

download_file()
{
    local url=$1
    local rename_file=$2

    echo "start download $url"

    if [ ! -z "$rename_file" ]
    then
        curl -L -o "$rename_file" "$url"
    else
        curl -L -O "$url"
        if [ $? -ne 0 ]; then exit 1; fi
    fi
}

download_file 'https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.9.tar.xz'
download_file 'https://ftp.gnu.org/gnu/glibc/glibc-2.41.tar.xz'
download_file 'https://github.com/besser82/libxcrypt/releases/download/v4.4.38/libxcrypt-4.4.38.tar.xz'
download_file 'https://busybox.net/downloads/busybox-1.36.1.tar.bz2'
download_file 'https://www.netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2'
download_file 'https://www.netfilter.org/projects/libnftnl/files/libnftnl-1.2.9.tar.xz'
download_file 'https://www.netfilter.org/projects/libnfnetlink/files/libnfnetlink-1.0.2.tar.bz2'
download_file 'https://www.netfilter.org/projects/libnetfilter_conntrack/files/libnetfilter_conntrack-1.0.9.tar.bz2'
download_file 'https://www.netfilter.org/projects/nftables/files/nftables-1.1.1.tar.xz'
download_file 'https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.14.0.tar.xz'
download_file 'https://matt.ucc.asn.au/dropbear/releases/dropbear-2025.88.tar.bz2'
download_file 'https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz'

exit 0
