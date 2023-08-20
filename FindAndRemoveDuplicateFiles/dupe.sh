#!/bin/bash

# Function to prompt user for action
prompt_user() {
    local response=""
    while true; do
        read -p "$1" response
        case $response in
            [Yy] ) return 0;;
            [Nn] ) return 1;;
            [Aa] ) return 2;;
            [Cc] ) return 3;;
            [Dd] ) return 4;;
            * ) echo "Please answer yes, no, or all.";;
        esac
    done
}

# Function to log a message in syslog format
log_message() {
    echo "$(date +"%b %d %T") $(hostname) dupe.sh: $1"
}

# Function to display progress information
display_progress() {
    local current_index="$1"
    local total_files="$2"
    local timestamp="$3"
    local percentage="$4"

    log_message "Progress: [$current_index/$total_files] ($percentage%), Time: $timestamp"
}
# Print usage instructions when -h flag is used
if [ "$1" == "-h" ]; then
    log_message "Usage: $0 [folder1] [folder2] [exclude_directory]"
    log_message "Compare the contents of two folders recursively and find duplicate files."
    log_message "Optionally, provide a directory to exclude from comparison."
    log_message "Use --script to specify the name of the deletion script to be generated."
    exit
fi

# Check if --script flag is used
if [ "$1" == "--script" ]; then
    script_filename="$2"
    generating_script="true"
    shift 2
fi
# Version, publish date, author, email, and license
VERSION="1.2"
PUBLISH_DATE=$(date +"%b %d, %Y")
AUTHOR="Jeremiah Pegues"
EMAIL="jeremiah@pegues.io"
LICENSE="GNU General Public License v3.0"

# Print version, publish date, author, email, and license
log_message "Duplicate File Finder and Remover"
log_message "Version: $VERSION"
log_message "Publish Date: $PUBLISH_DATE"
log_message "Author: $AUTHOR"
log_message "Email: $EMAIL"
log_message "License: $LICENSE"

if [ ! "$1" == "--remove-all" ]; then

    # Check if enough folder paths are provided as arguments
    if [ -z "$2" ] || [ -z "$3" ]; then
        log_message "Usage: $0 [folder1] [folder2] [exclude_directory] (use -h for help)"
        exit 1
    fi

    folder1="$2"
    folder2="$3"

    # Check if exclude directory is provided as an argument
    if [ ! -z "$4" ]; then
        exclude_directory="$4"
        log_message "Excluding directory $exclude_directory from comparison."
    else
        exclude_directory=""
    fi
else
     # Check if enough folder paths are provided as arguments
    if [ -z "$3" ] || [ -z "$4" ]; then
        log_message "Usage: $0 [folder1] [folder2] [exclude_directory] (use -h for help)"
        exit 1
    fi

    folder1="$3"
    folder2="$4"

    # Check if exclude directory is provided as an argument
    if [ ! -z "$5" ]; then
        exclude_directory="$5"
        log_message "Excluding directory $exclude_directory from comparison."
    else
        exclude_directory=""
    fi   
fi
# List of system directories to ignore
ignore_list=".Trashes .Spotlight-V100 .fseventsd .TemporaryItems .DocumentRevisions-V100 .Sarasota"

# Determine the quickest way to perform duplicate discovery
if [ "$(find "$folder1" -type f | wc -l)" -lt "$(find "$folder2" -type f | wc -l)" ]; then
    smaller_folder="$folder1"
    larger_folder="$folder2"
else
    smaller_folder="$folder2"
    larger_folder="$folder1"
fi

# Calculate start time for smaller folder
start_time=$(date +%s)

# Create temporary files to store file lists
temp_file_folder1=$(mktemp "/tmp/folder1_list.XXXXXXXXXX")
temp_file_folder2=$(mktemp "/tmp/folder2_list.XXXXXXXXXX")

# Display initial status
log_message "Populating file list for smaller folder..."

# Populate temporary files with file lists (only filenames) for smaller folder
find "$smaller_folder" -type f -not -path "$smaller_folder/$exclude_directory/*" | grep -Ev "$ignore_list" | xargs -I{} basename {} | sort > "$temp_file_folder1"

# Calculate end time and duration
end_time=$(date +%s)
duration=$((end_time - start_time))

log_message "File list for smaller folder populated. Execution time: $duration seconds"

# Calculate start time for larger folder
start_time=$(date +%s)

# Display initial status
log_message "Populating file list for larger folder..."

# Populate temporary files with file lists (only filenames) for larger folder
find "$larger_folder" -type f -not -path "$larger_folder/$exclude_directory/*" | grep -Ev "$ignore_list" | xargs -I{} basename {} | sort > "$temp_file_folder2"

# Calculate end time and duration
end_time=$(date +%s)
duration=$((end_time - start_time))

log_message "File list for larger folder populated. Execution time: $duration seconds"

duplicates=$(comm -12 "$temp_file_folder1" "$temp_file_folder2")

if [ "$generating_script" != "true" ]; then
    duplicate_array=()
    while IFS= read -r file; do
        duplicate_array+=("$file")
    done <<< "$duplicates"

    total_files=${#duplicate_array[@]}
    options="[N] Do Nothing [A] Remove from $folder1 [B] Remove from $folder2 [C] Remove all from $folder1 [D] Remove all from $folder2"

    log_message "Found $total_files duplicate files."

# Check if --remove-all flag is used
if [ "$1" == "--remove-all" ]; then
    remove_all_folder="$2"
    case "$remove_all_folder" in
        "folder1")
            log_message "Removing all duplicate files from $folder1"
            for file_to_remove in "${duplicate_array[@]}"; do
                rm "$folder1/$file_to_remove"
                log_message "File removed from $folder1: $file_to_remove"
            done
            exit 0;;
        "folder2")
            log_message "Removing all duplicate files from $folder2"
            for file_to_remove in "${duplicate_array[@]}"; do
                rm "$folder2/$file_to_remove"
                log_message "File removed from $folder2: $file_to_remove"
            done
            exit 0;;
        *)
            log_message "Invalid folder specified for --remove-all. Use 'folder1' or 'folder2'.";;
    esac
fi
# Loop through duplicate files
for ((i = 0; i < ${#duplicate_array[@]}; i++)); do
    selected_file="${duplicate_array[$i]}"
    option_index=$((i + 1))
    current_progress=$((i + 1))
    percentage=$((current_progress * 100 / total_files))
    timestamp=$(date +"%T")

    display_progress "$current_progress" "$total_files" "$timestamp" "$percentage"
    
    log_message "File: $selected_file"
    log_message "$options"

    user_choice=""
    while [ -z "$user_choice" ]; do
        read -p "Select an option: " user_choice
        case $user_choice in
            [Aa] )
                rm "$folder1/$selected_file"
                log_message "File removed from $folder1";;
            [Bb] )
                rm "$folder2/$selected_file"
                log_message "File removed from $folder2";;
            [Cc] )
                find "$folder1" -type f -name "$selected_file" -exec rm {} \;
                log_message "All duplicates removed from $folder1"
                
                # Remove all remaining duplicate files starting from the current index
                for ((j = i; j < ${#duplicate_array[@]}; j++)); do
                    remaining_file="${duplicate_array[$j]}"
                    rm "$folder1/$remaining_file"
                    log_message "File removed from $folder1"
                done

                i=${#duplicate_array[@]}  # Skip remaining prompts
                break;;  # Break loop after applying to remaining files
            [Dd] )
                find "$folder2" -type f -name "$selected_file" -exec rm {} \;
                log_message "All duplicates removed from $folder2"
                
                # Remove all remaining duplicate files starting from the current index
                for ((j = i; j < ${#duplicate_array[@]}; j++)); do
                    remaining_file="${duplicate_array[$j]}"
                    rm "$folder2/$remaining_file"
                    log_message "File removed from $folder2"
                done

                i=${#duplicate_array[@]}  # Skip remaining prompts
                break;;  # Break loop after applying to remaining files
            * )
                log_message "Please choose a valid option.";;
        esac
    done
done

else
    echo "#!/bin/bash" > "$script_filename"
    chmod +x "$script_filename"

    while IFS= read -r file; do
        echo "rm \"$folder1/$file\"" >> "$script_filename"
    done <<< "$duplicates"

    log_message "Deletion script generated at $script_filename"
fi

# Clean up temporary files
rm "$temp_file_folder1"
rm "$temp_file_folder2"

log_message "Script execution complete."
