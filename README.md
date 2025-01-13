# theSimSweeper -- The Sims 4 Mod Cleanup Tool

## Overview
**theSimSweeper** is a script designed to help Sims 4 (and possibly older versions) players clean up their mods folder by identifying and handling duplicate mod files. The tool groups mod files by their filename, keeps the newest version (based on last modified date), and moves the older duplicates to a specified folder, ensuring a cleaner and more organized mods folder.

---

## Features
- **Duplicate Detection**: Identifies duplicate mod files by filename and keeps the newest version based on the `Last modified` timestamp.
- **File Filtering**: Optionally filter by file extension (e.g., `.package`, `.ts4script`).
- **Formatted Output**: Displays duplicate file details in a clean, readable format.
- **Log File Generation**: Automatically generates a log file to track moved duplicates.
- **Cross-Platform Support**: Available for both Windows (PowerShell) and macOS (Bash/Zsh).
- **Progress Tracking**: Provides a simple progress bar while processing duplicates.

---

## NOW AVAILABLE -- macOS VERSION! 🚀
**For macOS users** (and other Unix-like systems), we've added a **Bash/Zsh** version of the script!

With the **macOS version** of theSimSweeper, you can now easily manage your mods on your Mac. The process is similar to the PowerShell script for Windows, but tailored for macOS terminal environments. Say goodbye to duplicates and keep your Mods folder clean!

## Installation

### Prerequisites
- Windows: PowerShell (comes pre-installed on Windows).
- macOS: Bash or Zsh (comes pre-installed on macOS).
- Access to your Sims 4 Mods folder.
- Basic knowledge of running scripts in PowerShell (Windows) or Terminal (macOS).

### Steps
1. **Download the script**: Save the `theSimSweeper.ps1` script to your desired location.
2. **Modify folder paths** (optional): 
    - Open the script and update the `$defaultModsFolder` and `$defaultDestinationFolder` variables if you want to use custom paths. 
    - By default, the script uses the following paths:
      - Mods folder: `C:\Users\monte\Documents\Electronic Arts\The Sims 4\Mods`
      - Destination folder: `C:\Users\monte\Documents\Electronic Arts\The Sims 4\Mods (place here to disable)`
3. **Run the script**:
    - Open PowerShell in the directory where the script is saved.
    - Execute the script by typing `.\theSimSweeper.ps1`.
    - Follow the prompts to proceed with scanning and managing duplicates.

**How to use the macOS version:**

1. **Download the macOS script**: Save the `theSimSweeper.sh` script to your preferred location.
2. **Make it executable**: Open a terminal and run the following command: ```chmod +x theSimSweeper.sh``` *(this just makes the script, which is basically a plain-text file, accessible like an application -- nothing crazy)
3. **Run the script**: ```./theSimSweeper.sh```

---

## How It Works

1. **Folder Path Setup**:
   - The script will first check if the default Mods folder and destination folder exist.
   - If the folders do not exist, it will prompt you to enter the correct paths or create them automatically.

2. **File Filtering**:
   - You can choose to filter by file extensions (e.g., `.package`, `.ts4script`).
   - If you leave this blank, it will process all files in the Mods folder.

3. **Identifying Duplicates**:
   - The script will scan the Mods folder recursively and group files by name.
   - It will then check for duplicates by comparing the last modified date of each file.

4. **Output**:
   - Duplicates will be displayed in a clean, easy-to-read format, with the newer and older file paths and their last modified dates.
   - Example output:

    ```
    ***DUPLICATES FOUND***
    ---
   **filename.package**
      NEWER: **Last modified date** | (path to newer file)
      OLDER: **Last modified date** | (path to older file)
    ---
    ```

5. **Move Duplicates**:
   - The script will ask for confirmation before moving all duplicates to the specified destination folder.
   - If any file already exists in the destination, it will rename the file by adding a timestamp to avoid overwriting.

6. **Logging**:
   - A log file will be generated in the destination folder with details of each file moved or any errors encountered.

---

## Changelog

### v1.7
- 1.7 (mac 1.1) - Modified output/display format for duplicate file list (again) because OCD. :)

### v1.6
- Modified output format for duplicate files to improve readability and include last modified dates.

### v1.5
- Fixed excessive new lines in output and log entries. Improved line breaks in `Write-Host` and `Add-Content`.

### v1.4
- Added default folder paths and automatic path checking to skip prompts.

### v1.3
- Added error handling for file moves, file type filtering, logging, and a progress bar.

### v1.2
- Automatically lists all duplicates at once before prompting to move them.

### v1.1
- Added preview of duplicate files before prompting to move them.

### v1.0
- Initial release: Scans Mods folder, identifies duplicates, and moves them after confirmation.

---

## Known Issues
- The script is designed to work with The Sims 4 mods. It may work with other versions, but there are no guarantees.
- If the destination folder is not writable, the script may fail to move the duplicate files.

---

## Support
For issues, suggestions, or improvements, feel free to submit an issue or pull request.

---
