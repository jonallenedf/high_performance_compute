#!/bin/bash

# Find the 1TB disk
TARGET_SIZE="1T"
DISK=""
while IFS= read -r line; do
    if [[ $line == *"$TARGET_SIZE"* ]]; then
        DISK=$(echo $line | awk '{print $1}')
        break
    fi
done < <(lsblk -o NAME,SIZE -d -n | grep -i "sd")

if [ -z "$DISK" ]; then
    echo "No 1TB disk found"
    exit 1
fi

echo "Found 1TB disk: /dev/$DISK"

# Create a single partition on the disk
echo "Creating partition on /dev/$DISK"
(echo o; echo n; echo p; echo 1; echo; echo; echo w) | fdisk /dev/$DISK

# Format the new partition with ext4 filesystem
echo "Formatting partition /dev/${DISK}1"
mkfs.ext4 /dev/${DISK}1

# Create a mount point
MOUNT_POINT="/mnt/new_disk"
echo "Creating mount point at $MOUNT_POINT"
mkdir -p $MOUNT_POINT

# Mount the partition
echo "Mounting /dev/${DISK}1 to $MOUNT_POINT"
mount /dev/${DISK}1 $MOUNT_POINT

# Add mount to fstab
echo "Adding mount to /etc/fstab"
echo "/dev/${DISK}1    $MOUNT_POINT    ext4    defaults,users    0    2" >> /etc/fstab

# Create the 'hpc' directory in the mounted disk
HPC_DIR="$MOUNT_POINT/hpc_staging"
echo "Creating directory $HPC_DIR"
mkdir -p $HPC_DIR

# Create a symbolic link to the 'hpc' directory in the user's home directory
SYMLINK="$HOME/hpc_staging"
echo "Creating symlink to $HPC_DIR at $SYMLINK"
ln -s $HPC_DIR $SYMLINK

echo "Disk added, directory, and symlink created successfully"
