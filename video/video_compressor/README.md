# Video File Compressor
This batch script automates the **compression of video files** in a folder (and its subfolders) using **FFmpeg**. It preserves folder structure, copies all audio and subtitle tracks, and optionally uses **NVENC** hardware acceleration if available.

## Overview
1. Features
2. Notes
3. Changelog

----------

## Features

1.  **Folder Importing Mechanic**
    
    -   Prompts the user to enter a folder path.
        
    -   Creates a corresponding target folder next to the source folder, with a `- compressed` suffix.
        
    -   Preserves the **subfolder structure** when saving compressed files.
        
2.  **Video Compression**
    
    -   Processes video files with the following extensions:  
        `.mp4, .mkv, .avi, .mov, .flv, .wmv, .mpeg, .mpg, .webm, .m4v, .mts, .m2ts, .3gp, .ts, .vob`
        
    -   Compresses video using **H.265 (HEVC)**:
        
        -   Default: `libx265` CPU encoding or `hevc_nvenc` NVENC hardware encoding (if GPU supports it).
        
    -   Copies **all audio tracks** (`-map 0 -c:a copy`) so no audio is lost.
        
    -   Copies subtitle tracks (`-c:s copy`).
        
3.  **Non-Video Files**
    
    -   All non-video files are **copied as-is** into the target folder.
        
    -   Preserves folder structure.
        
4.  **Repeat Option**
    
    -   After finishing, the script prompts the user if they want to compress another folder.
        

----------

## Notes

-   FFmpeg and PowerShell must be installed and accessible in your system PATH.
    
-   Script works on **Windows CMD**.
    
-   Uses `SETLOCAL ENABLEDELAYEDEXPANSION` for safe variable handling.
    
-   Can handle **special characters** in folder/file names if FFmpeg supports UTF-8 paths.
    
-   If NVENC hardware acceleration fails, the script can be modified to fallback to **CPU encoding (`libx265`)**.

----------

## Changelog
### Version 1.1
- Script only copied first audio track. Fixed
- Now if present in the video file, also copying subtitles
### Version 1.0
- Released bug free video file compressor.
