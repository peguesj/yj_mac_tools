#!/usr/bin/env python

import sys
import os

def get_file_sizes(file_list_path):
    try:
        with open(file_list_path, 'r') as file_list:
            for line in file_list:
                filepath = line.strip()
                if os.path.exists(filepath):
                    size = os.path.getsize(filepath)
                    print(f"{size} {filepath}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: get_file_sizes.py [file_list_path]")
        sys.exit(1)
    
    file_list_path = sys.argv[1]
    get_file_sizes(file_list_path)
