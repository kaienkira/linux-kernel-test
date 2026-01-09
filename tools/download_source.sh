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
    local file_name=$2

    if [ -z "$filename" ]
    then
        file_name=`basename "$url"`
    fi

    # file already exists
    if [ -f "$src_dir"/"$file_name" ]
    then
        return 0
    fi

    # delete old version file
    local package_name=${file_name%%-*}
    find "$src_dir" -maxdepth 1 -type f -name "${package_name}*" -delete

    echo "start download $url -> $file_name"
    curl -L -o "$file_name" "$url"
    if [ $? -ne 0 ]; then exit 1; fi

    return 0
}

download_file 'https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.4.tar.xz'
download_file 'https://ftp.gnu.org/gnu/glibc/glibc-2.42.tar.xz'
download_file 'https://github.com/besser82/libxcrypt/releases/download/v4.4.38/libxcrypt-4.4.38.tar.xz'
download_file 'https://busybox.net/downloads/busybox-1.36.1.tar.bz2'
download_file 'https://www.netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2'
download_file 'https://www.netfilter.org/projects/libnftnl/files/libnftnl-1.3.1.tar.xz'
download_file 'https://www.netfilter.org/projects/libnfnetlink/files/libnfnetlink-1.0.2.tar.bz2'
download_file 'https://www.netfilter.org/projects/libnetfilter_conntrack/files/libnetfilter_conntrack-1.0.9.tar.bz2'
download_file 'https://www.netfilter.org/projects/nftables/files/nftables-1.1.6.tar.xz'
download_file 'https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.17.0.tar.xz'
download_file 'https://matt.ucc.asn.au/dropbear/releases/dropbear-2025.88.tar.bz2'
download_file 'https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz'

exit 0
