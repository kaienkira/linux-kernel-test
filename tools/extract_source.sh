#!/bin/bash

set -o pipefail

script_name=`basename "$0"`
script_abs_name=`readlink -f "$0"`
script_path=`dirname "$script_abs_name"`

src_dir=`readlink -f "$script_path"/../src`

cd "$src_dir"
if [ $? -ne 0 ]; then exit 1; fi

find . -maxdepth 1 -name '*.tar.*' -exec tar -xvf {} \;
if [ $? -ne 0 ]; then exit 1; fi

exit 0
