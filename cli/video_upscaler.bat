@echo off
setlocal EnableDelayedExpansion

REM Video Upscaler Windows helper
REM Requires ffmpeg in PATH (install via winget install ffmpeg  or download from ffmpeg.org)

set VERSION=1.0.0
set INPUT=%~1
set OUTPUT=
set FPS=60
set CRF=15
set PRESET=veryslow
set WIDTH=3840
set HEIGHT=2160
set MAX=0
set FORCE=0

if "%INPUT%"=="" (
  echo Usage: video_upscaler.bat input.mp4 [options]
  echo.
  echo Options:
  echo   --out FILE
  echo   --fps N
  echo   --crf N
  echo   --preset NAME
  echo   --max
  echo   --force
  exit /b 1
)

shift
:parse
if "%~1"=="" goto done_parse
if /i "%~1"=="--out" (
  set OUTPUT=%~2
  shift & shift & goto parse
)
if /i "%~1"=="--fps" (
  set FPS=%~2
  shift & shift & goto parse
)
if /i "%~1"=="--crf" (
  set CRF=%~2
  shift & shift & goto parse
)
if /i "%~1"=="--preset" (
  set PRESET=%~2
  shift & shift & goto parse
)
if /i "%~1"=="--max" (
  set MAX=1
  shift & goto parse
)
if /i "%~1"=="--force" (
  set FORCE=1
  shift & goto parse
)
shift
goto parse
:done_parse

if %MAX%==1 (
  set CRF=12
  set PRESET=veryslow
  set FPS=120
  echo Absolute Peak Upscale Mode enabled
)

if "%OUTPUT%"=="" (
  for %%F in ("%INPUT%") do set OUTPUT=%%~nF_Upscaled_%WIDTH%x%HEIGHT%_%FPS%fps.mp4
)

where ffmpeg >nul 2>&1
if errorlevel 1 (
  echo ERROR: ffmpeg not found in PATH.
  echo Install with: winget install ffmpeg
  echo Or download from https://ffmpeg.org and add to PATH.
  exit /b 1
)

echo.
echo ========================================
echo   Video Upscaler v%VERSION% (Windows)
echo   Target: %WIDTH%x%HEIGHT% @ %FPS%fps
echo   CRF %CRF% / Preset %PRESET%
echo ========================================
echo.

if %FORCE%==0 (
  if %FPS% GEQ 120 (
    echo WARNING: High FPS requested. This will heavily strain the CPU.
    echo Recommended: use a cloud GPU (RunPod, Vast.ai, etc.)
    echo See docs\CLOUD.md
    echo.
    set /p CONT=Continue on this PC? (y/N): 
    if /i not "!CONT!"=="y" exit /b 0
  )
)

set VF=scale=%WIDTH%:%HEIGHT%:flags=lanczos
if %FPS% GTR 30 (
  set VF=!VF!,minterpolate=fps=%FPS%:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1
)

echo Running peak encode... this will take time.
ffmpeg -y -i "%INPUT%" -vf "!VF!" -c:v libx264 -preset %PRESET% -crf %CRF% -c:a aac -b:a 320k -movflags +faststart "%OUTPUT%"

if errorlevel 1 (
  echo Encode failed.
  exit /b 1
)

echo.
echo Done! Output: %OUTPUT%
echo If it was too slow, rent a virtual computer next time.
endlocal
