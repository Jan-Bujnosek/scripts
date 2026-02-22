# Video to image sequence

This simple batch script upon dragging the desired video file onto it extracts a frame after set time of seconds using **FFmpeg**. It is **useful for calculating camera positions** for COLMAP data or 3D model calculation. For faster computing on Nvidia GPUs it uses **CUDA** hardware acceleration.

I created this script because for some reason RealityScan's video import is really buggy on my computer, so i just plop this file alongside the videofile and it's done fairly quickly.

----------

## Notes

- FFmpeg and PowerShell must be installed and accessible in your system PATH.

- Script works on **Windows CMD**.

- Can handle **special characters** in folder/file names if FFmpeg supports UTF-8 paths.
