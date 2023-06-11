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

# Expand the tilde symbol to the user's home directory
SMART_FOLDER="${SMART_FOLDER/#\~/$HOME}"

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

# Get the number of files to be created
file_count=$(find "$SMART_FOLDER" -type f | wc -l)
echo "Number of files to be created: $file_count"

# Mount the smart folder as a drive
mount -t smbfs "$SMART_FOLDER" "$MOUNT_POINT"

# Check if the mount operation was successful
if [ $? -eq 0 ]; then
    echo "Smart folder mounted successfully at $MOUNT_POINT"
    
    # Create symbolic links to the contents of the smart folder
    file_index=0
    total_progress=50
    
    for item in "$SMART_FOLDER"/*; do
        item_basename=$(basename "$item")
        
        # Determine the most compatible link type based on the item's source
        link_type=""
        if [[ -f "$item" ]]; then
            link_type="Hard Link"
        elif [[ -d "$item" ]]; then
            link_type="Symbolic Link"
        fi
        
        # Display progress and verbose messaging
        ((file_index++))
        progress=$((file_index * total_progress / file_count))
        echo -ne "[$progress%] Creating $link_type: $item_basename...\r"
        
        # Create the appropriate type of link
        if [[ -f "$item" ]]; then
            ln "$item" "$MOUNT_POINT/$item_basename"
        elif [[ -d "$item" ]]; then
            ln -s "$item" "$MOUNT_POINT/$item_basename"
        fi
    done
    
    echo -e "\nSymbolic links created to the contents of the smart folder"
else
    echo "Failed to mount the smart folder"
    # Clean up the created mount point directory
    rmdir "$MOUNT_POINT"
fi