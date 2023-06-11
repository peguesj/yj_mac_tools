---

# SmartFolderToSymbolicLink (Refactored)
Author: Jeremiah Pegues  
License: GNU General Public License v3.0  
Version: 1.1.0  

## Description:

The script `smartFolderToSymbolicLink.sh` is an optimized version of the original Symbolic Link Management Script. This script creates symbolic links for all files found within a macOS Smart Folder (savedSearch) to another directory.

If a link exists already and points to the same file, no new link is created. However, if a link exists but points to a different file, a new link is created with an incremented suffix before the file extension.

This refactored version brings significant performance improvements by reducing unnecessary file system calls and efficiently handling file removals and additions when updating the links. It ensures quicker script execution, especially when dealing with a large number of files in the savedSearch, and only a few files change between updates.

## Prerequisites:
* macOS or any Unix-like operating system
* Bash shell (the script may not be compatible with other shells)

## Usage:

Make the script executable:

```
chmod +x smartFolderToSymbolicLink.sh
```

Run the script with the desired option:

* `-u <link_path>` - Update links. Replace `<link_path>` with the path to the folder where you want the links to be created.

Example:

```
./smartFolderToSymbolicLink.sh -u /path/to/link_folder
```

This will create symbolic links for all files in the savedSearch folder into the specified link_folder. If any links already exist, they will be updated according to the rules described above.

## Compatibility:
The script has been written for and tested on the Bash shell, which is the default shell on macOS and most Unix-like systems. If you're using a different shell, please switch to Bash before running the script.

## Disclaimer:

Please ensure you back up your data before running this or any other script that modifies the file system. While this script has been designed with safety in mind, there's always the potential for unintended side effects when modifying files and directories, particularly when those operations are automated.

---

