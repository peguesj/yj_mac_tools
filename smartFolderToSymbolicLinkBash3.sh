#!/bin/bash

# Function to create a symbolic link with suffix if a link already exists
create_symlink() {
    local source=$1
    local target=$2
    local base_target=$2
    local suffix=0

    while [ -e "$target" ]; do
        # If the link points to a different file, add a suffix
        if [ "$(readlink "$target")" != "$source" ]; then
            suffix=$((suffix + 1))
            target="${base_target}_$suffix"
        else
            # Exit if the link is already correct
            return
        fi
    done
    ln -s "$source" "$target"
}

# Function to update the symbolic links
update_links() {
    local saved_search_path=$1
    local link_path=$2

    # Check if the link directory exists, create it if it doesn't
    if [ ! -d "$link_path" ]; then
        mkdir -p "$link_path"
    fi

    # Create new links
    mdfind -0 -onlyin "$saved_search_path" . | while IFS= read -r -d '' file; do
        create_symlink "$file" "$link_path/$(basename "$file")"
    done

    # Remove old links
    find "$link_path" -type l | while read -r link; do
        if [ ! -e "$(readlink "$link")" ]; then
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
