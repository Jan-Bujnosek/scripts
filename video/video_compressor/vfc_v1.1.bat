@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:LOOP
REM =============================================
REM 0) Start timer
REM =============================================
SET "STARTTIME=%TIME%"

REM =============================================
REM 1) Ask the user for the source folder path
REM =============================================
ECHO.
ECHO Enter the full path to the folder you want to compress:
SET /P SOURCE=

REM =============================================
REM 2) Strip any surrounding quotes
REM =============================================
SET "SOURCE=%SOURCE:"=%"

REM =============================================
REM 3) Remove trailing backslash, if any
REM =============================================
IF "%SOURCE:~-1%"=="\" (
    SET "SOURCE=%SOURCE:~0,-1%"
)

REM =============================================
REM 4) Verify that SOURCE exists and is a directory
REM =============================================
IF NOT EXIST "%SOURCE%\." (
    ECHO.
    ECHO Error:  "%SOURCE%" is not a valid directory.
    ECHO Make sure you typed the path exactly, without extra quotes.
    GOTO LOOP
)

REM =============================================
REM 5) Determine PARENT folder and FOLDERNAME
REM =============================================
FOR %%I IN ("%SOURCE%") DO (
    SET "PARENT=%%~dpI"
    SET "FOLDERNAME=%%~nxI"
)

REM =============================================
REM 6) Define the TARGET root next to SOURCE, with " - compressed" suffix
REM =============================================
SET "TARGET=%PARENT%%FOLDERNAME% - compressed"

REM =============================================
REM 7) If TARGET already exists, abort
REM =============================================
IF EXIST "%TARGET%" (
    ECHO.
    ECHO Error:  Target folder "%TARGET%" already exists. Please remove or rename it and run again.
    GOTO LOOP
)

REM =============================================
REM 8) Create the TARGET root folder
REM =============================================
MKDIR "%TARGET%"
ECHO.
ECHO Created target directory:
ECHO   "%TARGET%"
ECHO.

REM =============================================
REM 9) List of video extensions to process
REM =============================================
SET "EXTLIST=.mp4 .mkv .avi .mov .flv .wmv .mpeg .mpg .webm .m4v .mts .m2ts .3gp .ts .vob"

REM =============================================
REM 10) Recurse through SOURCE, process each file
REM =============================================
FOR /R "%SOURCE%" %%F IN (*.*) DO (
    SET "THISEXT=%%~xF"
    CALL :CHECK_AND_PROCESS "%%F"
)

REM =============================================
REM 11) Timer end and duration calculation
REM =============================================
SET "ENDTIME=%TIME%"
CALL :DURATION "%STARTTIME%" "%ENDTIME%"

ECHO.
ECHO All done! Compressed files (H.265 NVENC in MP4) are in:
ECHO   "%TARGET%"
ECHO Total time taken: %DURATION%

REM =============================================
REM 12) Prompt to repeat
REM =============================================
ECHO.
SET /P CONT=Do you want to compress another folder? (Y/N):
IF /I "!CONT!"=="Y" GOTO LOOP

ECHO Exiting...
ENDLOCAL
EXIT /B 0

REM =============================================
REM Function to check file type and call processing
REM =============================================
:CHECK_AND_PROCESS
SET "EXTCHECK=%~x1"
SET "EXTCHECK=!EXTCHECK:~1!"

SET "ISVIDEO=0"
FOR %%E IN (%EXTLIST%) DO (
    SET "CAND=%%~xE"
    SET "CAND=!CAND:~1!"
    IF /I "!EXTCHECK!"=="!CAND!" SET "ISVIDEO=1"
)

IF "!ISVIDEO!"=="1" (
    CALL :PROCESS_VIDEO "%~1"
) ELSE (
    CALL :COPY_OTHER "%~1"
)
GOTO :EOF

REM =============================================
REM Function to compress video using NVENC
REM =============================================
:PROCESS_VIDEO
SET "FULLPATH=%~1"
SET "FILEDIR=%~dp1"
SET "RELATIVE=!FILEDIR:%SOURCE%\=!"
SET "DSTDIR=%TARGET%\!RELATIVE!"
IF NOT EXIST "!DSTDIR!" MKDIR "!DSTDIR!"

SET "BASENAME=%~n1"
SET "DSTFILE=!DSTDIR!\!BASENAME!.mp4"

ECHO ------------------------------------------------------------
ECHO Compressing (H.265 NVENC → MP4):
ECHO   From: "%FULLPATH%"
ECHO   To:   "%DSTFILE%"

ffmpeg -y -hwaccel cuda -i "%FULLPATH%" ^
    -map 0 -c:v hevc_nvenc -preset p4 -rc vbr -cq 28 -c:a copy -c:s copy "%DSTFILE%"

IF %ERRORLEVEL% NEQ 0 (
    ECHO   [ERROR] ffmpeg failed on "%FULLPATH%"
) ELSE (
    ECHO   [OK]    Encoded: "%BASENAME%.mp4"
)
ECHO.
GOTO :EOF

REM =============================================
REM Function to copy non-video files
REM =============================================
:COPY_OTHER
SET "FULLPATH=%~1"
SET "FILEDIR=%~dp1"
SET "RELATIVE=!FILEDIR:%SOURCE%\=!"
SET "DSTDIR=%TARGET%\!RELATIVE!"
IF NOT EXIST "!DSTDIR!" MKDIR "!DSTDIR!"

ECHO Copying other file:
ECHO   "%FULLPATH%" → "!DSTDIR!\"
XCOPY /Y /Q "%FULLPATH%" "!DSTDIR!\" >NUL
GOTO :EOF

REM =============================================
REM Function to calculate elapsed time
REM =============================================
:DURATION
REM %1 = start time, %2 = end time
SETLOCAL
SET "START=%~1"
SET "END=%~2"

FOR /F "tokens=1-4 delims=:.," %%a IN ("%START%") DO (
    SET /A "STARTSEC=(((%%a*60)+%%b)*60+%%c)"
)
FOR /F "tokens=1-4 delims=:.," %%a IN ("%END%") DO (
    SET /A "ENDSEC=(((%%a*60)+%%b)*60+%%c)"
)

REM Handle midnight wrap
IF %ENDSEC% LSS %STARTSEC% SET /A ENDSEC+=86400

SET /A DUR=%ENDSEC% - %STARTSEC%
SET /A H=%DUR% / 3600
SET /A M=(%DUR% %% 3600) / 60
SET /A S=%DUR% %% 60

ENDLOCAL & SET "DURATION=%H%h %M%m %S%s"
GOTO :EOF
