#!/bin/bash

# Parse command-line arguments
while getopts "f:m:" opt; do
    case $opt in
        f) SMART_FOLDER=$OPTARG ;;
        m) MOUNT_POINT=$OPTARG ;;
        *) echo "Invalid option: -$OPTARG. Usage: script.sh -f <smart_folder_path> -m <mount_point_path>"; exit 1 ;;
    esac
done

# Check if the required arguments are provided
if [ -z "$SMART_FOLDER" ] || [ -z "$MOUNT_POINT" ]; then
    echo "Missing required arguments. Usage: script.sh -f <smart_folder_path> -m <mount_point_path>"
    exit 1
fi

# Check if the smart folder is already mounted
if [ -d "$MOUNT_POINT" ]; then
    echo "Smart folder is already mounted at $MOUNT_POINT"
    exit 0
fi

# Create the mount point directory if it does not exist
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir "$MOUNT_POINT"
    if [ $? -ne 0 ]; then
        echo "Failed to create the mount point directory: $MOUNT_POINT"
        exit 1
    fi
fi

# Open the smart folder to automatically mount it
open -a Finder "$SMART_FOLDER"

# Wait for the smart folder to be mounted
while [ ! -d "$MOUNT_POINT" ]; do
    sleep 1
done

echo "Smart folder mounted successfully at $MOUNT_POINT"

# Create symbolic links to the contents of the smart folder
for item in "$SMART_FOLDER"/*; do
    ln -s "$item" "$MOUNT_POINT/$(basename "$item")"
done

echo "Symbolic links created to the contents of the smart folder"
