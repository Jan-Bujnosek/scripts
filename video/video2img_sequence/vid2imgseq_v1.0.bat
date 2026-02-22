@echo off
chcp 65001 >nul
title FFmpeg – export frames (JPG + HW decoding)

if "%~1"=="" (
    echo ERROR: Drag the video file onto this .bat file
    pause
    exit /b
)

set "INPUT=%~1"

echo.
set /p INTERVAL=Set interval in seconds (ex. 1, 2, 10): 

if "%INTERVAL%"=="" (
    echo ERROR: Interval not typed in.
    pause
    exit /b
)

if not exist "img" mkdir img

echo.
echo ==============================
echo File: %INPUT%
echo Interval: %INTERVAL% s
echo Output: JPG
echo HW decoding: NVIDIA CUDA (NVDEC)
echo ==============================
echo.

ffmpeg -hwaccel cuda -i "%INPUT%" -vf "fps=1/%INTERVAL%" -q:v 2 "img\frame_%%06d.jpg"

echo.
echo Success! Images are in the 'img' folder.
pause
