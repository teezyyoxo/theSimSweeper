# Script Name: theSimSweeper -- The Sims 4 (and probably older) Mod Cleanup Tool
# Author: @PBandJamf AKA @TeezyThaKidd
# Description: Identifies duplicate mod files by filename, keeps the newest version, and moves older duplicates to a specified folder.
#
# Changelog:
# v1.2 - Automatically lists all duplicates at once before prompting to move them.
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

# Collect all duplicates
$allDuplicates = @()

foreach ($group in $duplicateGroups) {
    # Sort the group by LastWriteTime descending (newest first)
    $sortedFiles = $group.Group | Sort-Object LastWriteTime -Descending
    
    # Keep the newest file, mark the rest as duplicates
    $fileToKeep = $sortedFiles[0]
    $duplicates = $sortedFiles[1..($sortedFiles.Count - 1)]

    foreach ($duplicate in $duplicates) {
        $allDuplicates += [PSCustomObject]@{
            GroupName = $group.Name
            KeepFile = $fileToKeep.FullName
            DuplicateFile = $duplicate.FullName
        }
    }
}

# Display all duplicates
if ($allDuplicates.Count -eq 0) {
    Write-Host "No duplicate files found." -ForegroundColor Green
    exit
}

Write-Host "\nDuplicate files detected:" -ForegroundColor Magenta
$allDuplicates | ForEach-Object {
    Write-Host "\nDuplicate group: $($_.GroupName)" -ForegroundColor Yellow
    Write-Host "File to keep (newest): $($_.KeepFile)" -ForegroundColor Green
    Write-Host "Duplicate to move: $($_.DuplicateFile)" -ForegroundColor Red
}

# Prompt once to move all duplicates
$confirmMoveAll = Read-Host "\nDo you want to move ALL listed duplicates to the destination folder? (Y/N)"
if ($confirmMoveAll -eq 'Y' -or $confirmMoveAll -eq 'y' -or $confirmMoveAll -eq 'yes' -or $confirmMoveAll -eq 'yup') {
    foreach ($item in $allDuplicates) {
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath ([IO.Path]::GetFileName($item.DuplicateFile))
        
        # Handle if the file already exists in the destination
        if (Test-Path $destinationPath) {
            $destinationPath = Join-Path -Path $destinationFolder -ChildPath ("$(Get-Date -Format yyyyMMdd_HHmmss)_" + [IO.Path]::GetFileName($item.DuplicateFile))
        }
        
        Move-Item -Path $item.DuplicateFile -Destination $destinationPath
        Write-Host "Moved: $($item.DuplicateFile) → $destinationPath" -ForegroundColor Green
    }
} else {
    Write-Host "No duplicates were moved." -ForegroundColor Cyan
}

Write-Host "Duplicate processing complete!" -ForegroundColor Green
