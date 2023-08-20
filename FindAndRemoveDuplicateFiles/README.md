# Duplicate File Finder and Remover

**Version:** 1.0  
**Publish Date:** August 20, 2023  
**Author:** Jeremiah Pegues  
**Email:** jeremiah@pegues.io  
**License:** GNU General Public License v3.0  

Duplicate File Finder and Remover is a shell script that helps you identify and manage duplicate files across two directories. It compares the contents of two folders, identifies duplicate files, and gives you options to remove them based on your preferences.

## Usage

```bash
./dupe.sh <folder1> <folder2> [--exclude <excluded_folder>] [--script <script_file>]
```

- `<folder1>`: The first directory to compare.
- `<folder2>`: The second directory to compare.
- `--exclude <excluded_folder>`: (Optional) Exclude a specific subdirectory from the comparison.
- `--script <script_file>`: (Optional) Generate a deletion script for the chosen files.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE). Feel free to use and modify it according to the terms of the license.

For any inquiries or support, please contact Jeremiah Pegues at jeremiah@pegues.io.