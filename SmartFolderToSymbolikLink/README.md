# SmartFolderToSymbolicLink (Refactored) & SmartFolderToSymbolicLinkBash3
Author: Jeremiah Pegues  
License: GNU General Public License v3.0  
Version: 1.4.0  

## Description:

This repository contains two scripts: `smartFolderToSymbolicLink.sh` and `smartFolderToSymbolicLinkBash3.sh`. Both scripts create symbolic links for all files found within a macOS Smart Folder (savedSearch) to another directory. If a link exists already and points to the same file, no new link is created. However, if a link exists but points to a different file, a new link is created with an incremented suffix before the file extension. Both scripts also check whether the destination directory exists, creating it if it doesn't.

`smartFolderToSymbolicLink.sh` is optimized for performance and requires Bash version 4.x or higher. It reduces unnecessary file system calls and efficiently handles file removals and additions when updating the links. 

`smartFolderToSymbolicLinkBash3.sh` is designed to be compatible with Bash 3.2, the default version on macOS. It performs the same function as `smartFolderToSymbolicLink.sh`, but may run slower when dealing with large numbers of files.

## Prerequisites:
* macOS or any Unix-like operating system
* Bash shell version 3.2 or higher (the scripts may not be compatible with other shells)

For optimal performance, consider upgrading Bash to version 4.x or higher using Homebrew:

1. Install Homebrew if you haven't already (https://brew.sh).
2. Use Homebrew to install a newer version of Bash: `brew install bash`
3. Add the new shell to the list of allowed shells: `sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'`
4. Change to the new shell: `chsh -s /usr/local/bin/bash`

## Usage:

Make the scripts executable:

```bash
chmod +x smartFolderToSymbolicLink.sh
chmod +x smartFolderToSymbolicLinkBash3.sh
```

Run the scripts with the desired options:

* `-s <saved_search_path>` - Path to the savedSearch file. Replace `<saved_search_path>` with the path to your savedSearch file.
* `-u <link_path>` - Update links. Replace `<link_path>` with the path to the folder where you want the links to be created. If the folder does not exist, the scripts will create it.

Example:

```bash
./smartFolderToSymbolicLink.sh -s /path/to/.savedSearch -u /path/to/link_folder
```

or

```bash
./smartFolderToSymbolicLinkBash3.sh -s /path/to/.savedSearch -u /path/to/link_folder
```

These commands will create symbolic links for all files in the savedSearch folder into the specified link_folder. If any links already exist, they will be updated according to the rules described above.

## Compatibility:
The scripts have been written for and tested on the Bash shell. `smartFolderToSymbolicLink.sh` requires Bash version 4.x or higher, while `smartFolderToSymbolicLinkBash3.sh` is compatible with Bash 3.2. 

## Disclaimer:

Please ensure you back up your data before running these or any other scripts that modify the file system. While these scripts have been designed with safety in mind, there's always the potential for unintended side effects when modifying files and directories, particularly when those operations are automated.
