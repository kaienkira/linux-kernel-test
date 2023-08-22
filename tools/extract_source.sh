#!/bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

src_dir=`readlink -f "$script_path"/../src`

cd "$src_dir"
if [ $? -ne 0 ]; then exit 1; fi

find . -maxdepth 1 -name '*.tar.gz' -exec tar -zxvf {} \;
if [ $? -ne 0 ]; then exit 1; fi
find . -maxdepth 1 -name '*.tar.xz' -exec tar -Jxvf {} \;
if [ $? -ne 0 ]; then exit 1; fi
find . -maxdepth 1 -name '*.tar.bz2' -exec tar -jxvf {} \;
if [ $? -ne 0 ]; then exit 1; fi

exit 0
