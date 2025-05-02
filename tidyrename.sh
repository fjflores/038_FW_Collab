#!/bin/bash

# rename_tidydata.sh - Rename all TidyData.mat files in a target directory to include a suffix

# Help message
show_help() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run] <suffix> [target_directory]

This script recursively finds and renames all 'TidyData.mat' files to 'TidyData_<suffix>.mat'.

Arguments:
  --dry-run            (Optional) Show what would be renamed without making changes.
  <suffix>             The text to append after 'TidyData_' in the filename.
  [target_directory]   (Optional) Path to the directory to search in. Default is the current directory.

Examples:
  $(basename "$0") pro
  $(basename "$0") --dry-run pro ./data

EOF
}

# Default values
dry_run=false
suffix=""
target_dir="."

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            dry_run=true
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$suffix" ]; then
                suffix="$arg"
            elif [ "$target_dir" = "." ]; then
                target_dir="$arg"
            fi
            ;;
    esac
done

# Validate
if [ -z "$suffix" ]; then
    echo "Error: Suffix is required."
    show_help
    exit 1
fi

if [ ! -d "$target_dir" ]; then
    echo "Error: Target directory '$target_dir' does not exist."
    exit 1
fi

# Perform renaming or dry run
find "$target_dir" -type f -name "TidyData.mat" | while read -r file; do
    dir=$(dirname "$file")
    new_file="$dir/TidyData_${suffix}.mat"
    if $dry_run; then
        echo "[Dry Run] Would rename: $file -> $new_file"
    else
        mv "$file" "$new_file"
        echo "Renamed: $file -> $new_file"
    fi
done
