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

    echo "start download $url"

    curl -O "$url"
    if [ $? -ne 0 ]; then exit 1; fi
}

download_file 'https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.19.tar.xz'
download_file 'https://busybox.net/downloads/busybox-1.35.0.tar.bz2'
download_file 'https://ftp.gnu.org/gnu/grub/grub-2.06.tar.xz'
download_file 'https://www.netfilter.org/projects/nftables/files/nftables-1.0.4.tar.bz2'
download_file 'https://www.netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2'
download_file 'https://www.netfilter.org/projects/libnftnl/files/libnftnl-1.2.2.tar.bz2'
download_file 'https://www.netfilter.org/projects/libnfnetlink/files/libnfnetlink-1.0.2.tar.bz2'
download_file 'https://www.netfilter.org/projects/libnetfilter_conntrack/files/libnetfilter_conntrack-1.0.9.tar.bz2'

exit 0
