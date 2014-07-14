#!/bin/bash
#
# Prepares an already attached EBS volume for mounting
#

if [[ $# -lt 2 ]] || [[ $EUID -ne 0 ]]; then
  echo "Usage: sudo $0 /dev/[disk name] /mount-point"
  exit 1;
fi

if [[ $(grep -c "/etc/fstab" "$1") -gt 0 ]]; then
	echo "Error: drive already listed in /etc/fstab"
	exit 1
fi

set -x -e

# check device
file -s "$1"

# create filesystem
mkfs -t ext4 "$1"

# create mount point
if [[ ! -d "$2" ]]; then
	mkdir -p "$2"
fi

# create fstab entry
echo "$1    $2   ext4    defaults,nofail,nobootwait   0   2" >> /etc/fstab

# mount!
mount -a
