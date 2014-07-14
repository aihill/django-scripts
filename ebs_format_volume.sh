#!/bin/bash
#
# Prepares an already attached EBS volume for mounting
#

if [[ $# -lt 2 ]] || [[ $EUID -ne 0 ]]; then
  echo "Usage: sudo $0 /dev/[disk name] /mount-point"
  exit 1
fi

if [[ $(grep -c "$1" "/etc/fstab") -gt 0 ]]; then
	echo "Error: drive already listed in /etc/fstab"
	exit 1
fi

set -x -e

echo "$0: check device..."
file -s "$1"

echo "$0: create filesystem..."
mkfs -t ext4 "$1"

if [[ ! -d "$2" ]]; then
	echo "$0: create mount point: $2"
	mkdir -p "$2"
else
	echo "$0: already created: $2"
fi

echo "$0: update fstab..."
echo "$1    $2   ext4    defaults,nofail,nobootwait   0   2" >> /etc/fstab

echo "$0: mount..."
mount -a

echo "$0: done."
