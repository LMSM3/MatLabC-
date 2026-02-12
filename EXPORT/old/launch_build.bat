@echo off
REM launch_build.bat - Launch build in external terminal (Windows)

set SCRIPT_DIR=%~dp0

REM Open new Command Prompt window and run build
start "MatLabC++ Build" cmd /k "cd /d %SCRIPT_DIR% && setup_project.bat && build.bat install && echo. && echo Build complete! && pause"

echo Build launched in new window!
