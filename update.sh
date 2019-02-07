#!/bin/bash

set -eu

revs=($(
    curl "http://reta-vortaro.de/tgz/index.html" | \
        sed -rn 's/.*<a +href="(revonov_....-..-.._....-..-...zip)".*/\1/p' | \
        sort
      ))

script_dir=$(cd $(dirname "$0") && pwd)
tmp_dir="$script_dir/tmp"

rm -rf "$tmp_dir"
mkdir -p "$tmp_dir"

subdirs=(cfg  dtd  smb  stl  xml  xsl)

for x in "${revs[@]}"; do
    if git rev-parse ":/Updated to $x"; then
        echo "Skipping $x which is already in the repo"
        continue
    fi

    curl -o "$tmp_dir/$x" "http://reta-vortaro.de/tgz/$x"
    zip_dir="$tmp_dir/ext-$x"
    unzip -d "$zip_dir" "$tmp_dir/$x"

    for subdir in "${subdirs[@]}"; do
        if test -d "$zip_dir/revo/$subdir" &&
                test $(ls "$zip_dir/revo/$subdir" | wc -l) -gt 0; then
            mv "$zip_dir/revo/$subdir/"* "$script_dir/$subdir/"
        fi
    done

    git add "${subdirs[@]}"
    git commit -m "Updated to $x"
done

rm -rf "$tmp_dir"
