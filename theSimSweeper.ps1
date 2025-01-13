# If you're here, I assume you read the readme. If not, you should probably do that first.

# Script Name: theSimSweeper -- The Sims 4 (and probably older) Mod Cleanup Tool
# Author: @PBandJamf AKA @TeezyThaKidd
# Description: Identifies duplicate mod files by filename, keeps the newest version, and moves older duplicates to a specified folder.
#
# Changelog:
# v1.7 - Modified output/display format for duplicate file list (again) because OCD. :)
# v1.6 - Modified output/display format for duplicate file list by adding a cleaner display with newer/older file details and last modified dates to help the user more quickly visually verify discrepancies.
# v1.5 - Fixed excessive new lines in output and log entries. Streamlined `Write-Host` and `Add-Content` to handle line breaks correctly.
# v1.4 - Added default folder paths and automatic path checking to skip prompts.
# v1.3 - Added error handling for file moves, file type filtering, logging, and a progress bar.
# v1.2 - Automatically lists all duplicates at once before prompting to move them.
# v1.1 - Added preview of duplicate files before prompting to move them.
# v1.0 - Initial release: Scans Mods folder, identifies duplicates, and moves them after confirmation.

# Default folder paths
$defaultModsFolder = "C:\Users\monte\Documents\Electronic Arts\The Sims 4\Mods"
$defaultDestinationFolder = "C:\Users\monte\Documents\Electronic Arts\The Sims 4\Mods (place here to disable)"

# Check if default Mods folder exists, else prompt user
if (Test-Path $defaultModsFolder) {
    $modsFolder = $defaultModsFolder
    Write-Host "Using default Mods folder: $modsFolder" -ForegroundColor Green
} else {
    $modsFolder = Read-Host "Enter the path to your Mods folder"
}

# Check if default destination folder exists, else prompt user
if (Test-Path $defaultDestinationFolder) {
    $destinationFolder = $defaultDestinationFolder
    Write-Host "Using default destination folder: $destinationFolder" -ForegroundColor Green
} else {
    $destinationFolder = Read-Host "Enter the path to the folder where duplicates should be moved"
}

# Prompt for specific file extensions to check (optional)
$fileExtensions = Read-Host "Enter file extensions to filter by (comma-separated, e.g., .package,.ts4script) or leave blank for all files"
$fileExtensionArray = @()
if ($fileExtensions -ne '') {
    $fileExtensionArray = $fileExtensions -split ',' | ForEach-Object { $_.Trim() }
}

# Validate the folder paths
if (!(Test-Path $modsFolder)) {
    Write-Host "The specified Mods folder path does not exist." -ForegroundColor Red
    exit
}

if (!(Test-Path $destinationFolder)) {
    Write-Host "The specified destination folder does not exist. Creating it now."
    New-Item -ItemType Directory -Path $destinationFolder
}

# Initialize log file
$logFile = Join-Path -Path $destinationFolder -ChildPath "DuplicateModsLog_$(Get-Date -Format yyyyMMdd_HHmmss).txt"

# Get all files in the Mods folder (including subfolders), optionally filtering by extension
if ($fileExtensionArray.Count -gt 0) {
    $files = Get-ChildItem -Path $modsFolder -Recurse -File | Where-Object { $fileExtensionArray -contains $_.Extension }
} else {
    $files = Get-ChildItem -Path $modsFolder -Recurse -File
}

# Group files by name
$duplicateGroups = $files | Group-Object Name | Where-Object { $_.Count -gt 1 }

# Collect all duplicates
$allDuplicates = @()

foreach ($group in $duplicateGroups) {
    $sortedFiles = $group.Group | Sort-Object LastWriteTime -Descending
    $fileToKeep = $sortedFiles[0]
    $duplicates = $sortedFiles[1..($sortedFiles.Count - 1)]

    foreach ($duplicate in $duplicates) {
        $allDuplicates += [PSCustomObject]@{
            GroupName = $group.Name
            KeepFile = $fileToKeep.FullName
            DuplicateFile = $duplicate.FullName
            KeepFileModified = $fileToKeep.LastWriteTime
            DuplicateFileModified = $duplicate.LastWriteTime
        }
    }
}

if ($allDuplicates.Count -eq 0) {
    Write-Host "No duplicate files found." -ForegroundColor Green
    exit
}

Write-Host "***DUPLICATES FOUND***" -ForegroundColor Cyan
Write-Host "---" -ForegroundColor Cyan

$allDuplicates | ForEach-Object {
    Write-Host "**$($_.GroupName)" -ForegroundColor Yellow
    Write-Host "NEWER: $($_.KeepFileModified) $($_.KeepFile)" -ForegroundColor Green
    Write-Host "OLDER: $($_.DuplicateFileModified) $($_.DuplicateFile)" -ForegroundColor Red
    Write-Host "---" -ForegroundColor Cyan
}

$confirmMoveAll = Read-Host "Do you want to move ALL listed duplicates to the destination folder? (Y/N)"
if ($confirmMoveAll -match '^(Y|y|yes|yup)$') {
    $total = $allDuplicates.Count
    $count = 0

    foreach ($item in $allDuplicates) {
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath ([IO.Path]::GetFileName($item.DuplicateFile))
        if (Test-Path $destinationPath) {
            $destinationPath = Join-Path -Path $destinationFolder -ChildPath ("$(Get-Date -Format yyyyMMdd_HHmmss)_" + [IO.Path]::GetFileName($item.DuplicateFile))
        }
        try {
            Move-Item -Path $item.DuplicateFile -Destination $destinationPath -ErrorAction Stop
            Write-Host "Moved: $($item.DuplicateFile) → $destinationPath" -ForegroundColor Green
            Add-Content -Path $logFile -Value "Moved: $($item.DuplicateFile) → $destinationPath"
        } catch {
            Write-Host "Failed to move: $($item.DuplicateFile)" -ForegroundColor Red
            Add-Content -Path $logFile -Value "Failed to move: $($item.DuplicateFile)"
        }
        $count++
        Write-Progress -Activity "Moving Duplicates" -Status "$count of $total files moved" -PercentComplete (($count / $total) * 100)
    }
} else {
    Write-Host "No duplicates were moved." -ForegroundColor Cyan
    Add-Content -Path $logFile -Value "No duplicates were moved."
}

Write-Host "Duplicate processing complete! Log saved to $logFile" -ForegroundColor Green
