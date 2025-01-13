# If you're here, I assume you read the readme. If not, you should probably do that first.

#!/bin/bash

# Script Name: theSimSweeper -- The Sims 4 Mod Cleanup Tool (Bash Version)
# Author: @PBandJamf AKA @TeezyThaKidd
# Description: Identifies duplicate mod files by filename, keeps the newest version, and moves older duplicates to a specified folder.
#
# Changelog:
# v1.1 - Modified output/display format for duplicate file list (again) because OCD. :)
# v1.0 - Initial release: Scans Mods folder, identifies duplicates, and moves them after confirmation.

# Default folder paths
defaultModsFolder="$HOME/Documents/Electronic Arts/The Sims 4/Mods"
defaultDestinationFolder="$HOME/Documents/Electronic Arts/The Sims 4/Mods (place here to disable)"

# Check if default Mods folder exists, else prompt user
if [ -d "$defaultModsFolder" ]; then
    modsFolder="$defaultModsFolder"
    echo "Using default Mods folder: $modsFolder"
else
    read -p "Enter the path to your Mods folder: " modsFolder
fi

# Check if default destination folder exists, else prompt user
if [ -d "$defaultDestinationFolder" ]; then
    destinationFolder="$defaultDestinationFolder"
    echo "Using default destination folder: $destinationFolder"
else
    read -p "Enter the path to the folder where duplicates should be moved: " destinationFolder
fi

# Validate the folder paths
if [ ! -d "$modsFolder" ]; then
    echo "The specified Mods folder path does not exist." >&2
    exit 1
fi

if [ ! -d "$destinationFolder" ]; then
    echo "The specified destination folder does not exist. Creating it now."
    mkdir -p "$destinationFolder"
fi

# Prompt for specific file extensions to check (optional)
read -p "Enter file extensions to filter by (comma-separated, e.g., .package,.ts4script) or leave blank for all files: " fileExtensions

# Convert extensions into an array
IFS=',' read -r -a fileExtensionArray <<< "$fileExtensions"

# Find all files in the Mods folder (including subfolders), optionally filtering by extension
if [ ${#fileExtensionArray[@]} -gt 0 ]; then
    find "$modsFolder" -type f | grep -E "\.(${fileExtensionArray[*]//,/|})$" > files_to_check.txt
else
    find "$modsFolder" -type f > files_to_check.txt
fi

# Initialize log file
logFile="$destinationFolder/DuplicateModsLog_$(date +%Y%m%d_%H%M%S).txt"

# Group files by name and detect duplicates
duplicates=()
while read -r file; do
    fileName=$(basename "$file")
    fileModTime=$(stat -f "%m" "$file")

    if [ -z "${duplicates["$fileName"]}" ]; then
        duplicates["$fileName"]="$file:$fileModTime"
    else
        # Existing duplicate group, compare the times
        existingFilePath=${duplicates["$fileName"]%:*}
        existingModTime=${duplicates["$fileName"]#*:}

        if [ "$fileModTime" -gt "$existingModTime" ]; then
            # Newer file is the current one
            duplicates["$fileName"]="$file:$fileModTime"
            olderDuplicate="$existingFilePath"
        else
            # Older file is the current one
            olderDuplicate="$file"
        fi
    done
done < files_to_check.txt

# Check if any duplicates were found
if [ ${#duplicates[@]} -eq 0 ]; then
    echo "No duplicate files found."
    exit 0
fi

# Show duplicates with formatted output
echo -e "\n*** DUPLICATES FOUND ***"

for key in "${!duplicates[@]}"; do
    newFile=${duplicates["$key"]%:*}
    newModTime=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$newFile")
    olderDuplicatePath="$olderDuplicate"
    olderModTime=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$olderDuplicatePath")

    echo -e "\n---"
    echo -e "**$key**"
    echo -e "NEWER: $newModTime | $newFile"
    echo -e "OLDER: $olderModTime | $olderDuplicatePath"
    echo -e "---"
done

# Ask if user wants to move duplicates
read -p "Do you want to move ALL listed duplicates to the destination folder? (Y/N): " confirmMoveAll
if [[ "$confirmMoveAll" =~ ^[Yy](es|up)?$ ]]; then
    totalDuplicates=${#duplicates[@]}
    count=0

    for key in "${!duplicates[@]}"; do
        newFile=${duplicates["$key"]%:*}
        destinationPath="$destinationFolder/$(basename "$newFile")"

        if [ -f "$destinationPath" ]; then
            timestamp=$(date +%Y%m%d_%H%M%S)
            destinationPath="$destinationFolder/${timestamp}_$(basename "$newFile")"
        fi

        # Move the file
        mv "$newFile" "$destinationPath" && \
        echo "Moved: $newFile → $destinationPath" && \
        echo "Moved: $newFile → $destinationPath" >> "$logFile"

        count=$((count + 1))
        progress=$((count * 100 / totalDuplicates))
        echo -ne "Progress: $progress% ($count of $totalDuplicates)\r"
    done
    echo -e "\nAll duplicates moved successfully!"
else
    echo "No duplicates were moved."
    echo "No duplicates were moved." >> "$logFile"
fi

echo "Duplicate processing complete! Log saved to $logFile"
