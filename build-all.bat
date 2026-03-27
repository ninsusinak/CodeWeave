@echo off
REM Build script for CodeWeave - Cross-platform builds

setlocal enabledelayedexpansion

set PROJECT_PATH=CodeWeave.UI\CodeWeave.UI.csproj
set OUTPUT_DIR=dist

echo Building CodeWeave for all platforms...

REM Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Windows x64
echo Building for Windows x64...
dotnet publish "%PROJECT_PATH%" -c Release -r win-x64 -o "%OUTPUT_DIR%\win-x64"
if !errorlevel! neq 0 exit /b !errorlevel!

REM Windows ARM64
echo Building for Windows ARM64...
dotnet publish "%PROJECT_PATH%" -c Release -r win-arm64 -o "%OUTPUT_DIR%\win-arm64"
if !errorlevel! neq 0 exit /b !errorlevel!

REM macOS x64
echo Building for macOS x64...
dotnet publish "%PROJECT_PATH%" -c Release -r osx-x64 -o "%OUTPUT_DIR%\mac-x64"
if !errorlevel! neq 0 exit /b !errorlevel!

REM macOS ARM64
echo Building for macOS ARM64...
dotnet publish "%PROJECT_PATH%" -c Release -r osx-arm64 -o "%OUTPUT_DIR%\mac-arm64"
if !errorlevel! neq 0 exit /b !errorlevel!

REM Linux x64
echo Building for Linux x64...
dotnet publish "%PROJECT_PATH%" -c Release -r linux-x64 -o "%OUTPUT_DIR%\linux-x64"
if !errorlevel! neq 0 exit /b !errorlevel!

REM Linux ARM64
echo Building for Linux ARM64...
dotnet publish "%PROJECT_PATH%" -c Release -r linux-arm64 -o "%OUTPUT_DIR%\linux-arm64"
if !errorlevel! neq 0 exit /b !errorlevel!

echo All builds completed successfully!
echo Outputs are in the %OUTPUT_DIR% directory
pause
