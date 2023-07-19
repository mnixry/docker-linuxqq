#!/bin/bash -xe

git clone https://aur.archlinux.org/linuxqq.git /tmp/linuxqq
cd /tmp/linuxqq

# Read the latest commit hash and set it as output
hash=`git rev-parse --short HEAD`
echo "hash=$hash" >> $GITHUB_OUTPUT

while IFS='=' read -r key value; do
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    case "$key" in
        pkgrel) pkgrel="$value" ;;
        pkgver) pkgver="$value" ;;
        epoch) epoch="$value" ;;
    esac
done < .SRCINFO

# if epoch not euqal 2, exit with error
if [ "$epoch" != "2" ]; then
    echo "epoch not equal 2, exit with error"
    exit 1
fi

echo "pkgrel=$pkgrel" >> $GITHUB_OUTPUT
echo "pkgver=$pkgver" >> $GITHUB_OUTPUT