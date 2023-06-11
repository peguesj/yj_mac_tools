#!/bin/bash

# Function to create a symbolic link with suffix if a link already exists
function create_symlink() {
    local source=$1
    local target=$2
    local counter=1
    while [ -e "$target" ]; do
        # If the link points to a different file, add a suffix
        if [ "$(readlink "$target")" != "$source" ]; then
            target="${2}_$counter"
            counter=$((counter + 1))
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

    # Remove existing links
    find "$link_path" -type l -delete

    # Create new links
    mdfind -0 -onlyin "$saved_search_path" . | while IFS= read -r -d '' file; do
        create_symlink "$file" "$link_path/$(basename "$file")"
    done
}

# Function to validate the symbolic links
function validate_links() {
    local link_path=$1
    local remove_broken=$2

    # Check each link
    find "$link_path" -type l | while read -r link; do
        if [ ! -e "$link" ]; then
            # Remove or print message for broken links
            if [ "$remove_broken" = true ]; then
                rm "$link"
            else
                echo "Broken link: $link"
            fi
        fi
    done
}

# Main script
while getopts "u:r:v:" opt; do
    case "$opt" in
        u)
            update_links "/path/to/.savedSearch" "$OPTARG"
            ;;
        r)
            validate_links "/path/to/links" "$OPTARG"
            ;;
        v)
            validate_links "/path/to/links" false
            ;;
        *)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done

