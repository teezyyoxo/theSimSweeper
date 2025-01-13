# Script Name: theSimSweeper -- The Sims 4 (and probably older) Mod Cleanup Tool
# Author: @PBandJamf AKA @TeezyThaKidd
# Description: Identifies duplicate mod files by filename, keeps the newest version, and moves older duplicates to a specified folder.
#
# Changelog:
# v1.1 - Added preview of duplicate files before prompting to move them.
# v1.0 - Initial release: Scans Mods folder, identifies duplicates, and moves them after confirmation.
#
# Prompt for the Mods folder path
$modsFolder = Read-Host "Enter the path to your Mods folder"

# Prompt for the destination folder for duplicates
$destinationFolder = Read-Host "Enter the path to the folder where duplicates should be moved"

# Validate the folder paths
if (!(Test-Path $modsFolder)) {
    Write-Host "The specified Mods folder path does not exist." -ForegroundColor Red
    exit
}

if (!(Test-Path $destinationFolder)) {
    Write-Host "The specified destination folder does not exist. Creating it now."
    New-Item -ItemType Directory -Path $destinationFolder
}

# Get all files in the Mods folder (including subfolders)
$files = Get-ChildItem -Path $modsFolder -Recurse -File

# Group files by name
$duplicateGroups = $files | Group-Object Name | Where-Object { $_.Count -gt 1 }

foreach ($group in $duplicateGroups) {
    # Sort the group by LastWriteTime descending (newest first)
    $sortedFiles = $group.Group | Sort-Object LastWriteTime -Descending
    
    # Keep the newest file, mark the rest as duplicates
    $fileToKeep = $sortedFiles[0]
    $duplicates = $sortedFiles[1..($sortedFiles.Count - 1)]

    Write-Host "\nDuplicate group detected for file: $($group.Name)" -ForegroundColor Magenta
    Write-Host "File to keep (newest): $($fileToKeep.FullName)" -ForegroundColor Green
    Write-Host "Files marked as duplicates:" -ForegroundColor Yellow
    foreach ($duplicate in $duplicates) {
        Write-Host " - $($duplicate.FullName)"
    }

    $confirmMove = Read-Host "Do you want to move these duplicates to the destination folder? (Y/N)"
    if ($confirmMove -eq 'Y' -or $confirmMove -eq 'y') {
        foreach ($duplicate in $duplicates) {
            $destinationPath = Join-Path -Path $destinationFolder -ChildPath $duplicate.Name
            
            # Handle if the file already exists in the destination
            if (Test-Path $destinationPath) {
                $destinationPath = Join-Path -Path $destinationFolder -ChildPath ("$(Get-Date -Format yyyyMMdd_HHmmss)_" + $duplicate.Name)
            }
            
            Move-Item -Path $duplicate.FullName -Destination $destinationPath
            Write-Host "Moved to: $destinationPath" -ForegroundColor Green
        }
    } else {
        Write-Host "Skipped moving duplicates for: $($group.Name)" -ForegroundColor Cyan
    }
}

Write-Host "Duplicate processing complete!" -ForegroundColor Green
