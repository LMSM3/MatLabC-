@echo off
REM test_demo.bat
REM Quick test for Python demo on Windows

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo MatLabC++ Demo Test - Windows
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

REM Check for Python
echo Checking for Python...
where python >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ Python found[0m
    python --version
    echo.
    echo Running self-installing demo...
    echo.
    python demos\self_install_demo.py
    goto :end
)

where python3 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ Python3 found[0m
    python3 --version
    echo.
    echo Running self-installing demo...
    echo.
    python3 demos\self_install_demo.py
    goto :end
)

where py >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ Python launcher found[0m
    py --version
    echo.
    echo Running self-installing demo...
    echo.
    py demos\self_install_demo.py
    goto :end
)

REM Python not found
echo [33m! Python not found[0m
echo.
echo Python is required for this demo.
echo.
echo Install Python:
echo   1. Download from https://www.python.org/downloads/
echo   2. Or install from Microsoft Store
echo   3. Make sure to check "Add Python to PATH"
echo.
echo After installing Python, run this script again.
echo.
echo Alternatively, try the C++ demo (no Python required):
echo   1. Install MinGW or Visual Studio
echo   2. Run: compile_demo.bat
echo   3. Run: demos\green_square_demo.exe
echo.

:end
pause
