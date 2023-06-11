#!/bin/bash

# Variables for improved performance
declare -A counter
declare -A link_check

# Function to create a symbolic link with suffix if a link already exists
function create_symlink() {
    local source=$1
    local target=$2
    local base_target=$2
    counter[$base_target]=1

    while [ -e "$target" ]; do
        # If the link points to a different file, add a suffix
        if [ "$(readlink "$target")" != "$source" ]; then
            target="${base_target}_${counter[$base_target]}"
            counter[$base_target]=$((counter[$base_target] + 1))
        else
            # Exit if the link is already correct
            return
        fi
    done
    ln -s "$source" "$target"
}

# Function to update the symbolic links
function update_links() {
    local saved_search_path=$1
    local link_path=$2

    # Check if the link directory exists, create it if it doesn't
    if [ ! -d "$link_path" ]; then
        mkdir -p "$link_path"
    fi

    # Create new links
    mdfind -0 -onlyin "$saved_search_path" . | while IFS= read -r -d '' file; do
        link_check["$file"]=true
        create_symlink "$file" "$link_path/$(basename "$file")"
    done

    # Remove old links
    find "$link_path" -type l | while read -r link; do
        if [ "${link_check[$(readlink "$link")]}" != true ]; then
            rm "$link"
        fi
    done
}

# Main script
while getopts "s:u:" opt; do
    case "$opt" in
        s)
            saved_search_path="$OPTARG"
            ;;
        u)
            link_path="$OPTARG"
            ;;
        *)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done

# Call the function with the provided parameters
update_links "$saved_search_path" "$link_path"
