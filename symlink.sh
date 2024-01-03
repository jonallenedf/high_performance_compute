#!/bin/bash

# Specify the full path of the existing 'hpc' directory
HPC_DIR="/mnt/new_disk/hpc"

# Specify the desired symlink location in your home directory
SYMLINK="$HOME/hpc"

# Check if the 'hpc' directory exists
if [ -d "$HPC_DIR" ]; then
    # Create the symlink
    ln -sfn $HPC_DIR $SYMLINK
    echo "Symlink created at $SYMLINK"
else
    echo "Error: Directory $HPC_DIR does not exist."
fi
