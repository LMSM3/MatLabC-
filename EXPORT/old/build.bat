@echo off
REM build.bat - Windows build script for MatLabC++ v0.3.0
REM
REM Usage:
REM   build.bat              Full build
REM   build.bat clean        Clean build
REM   build.bat install      Build and install
REM   build.bat package      Create distribution package

setlocal EnableDelayedExpansion

set PROJECT_NAME=MatLabC++
set VERSION=0.3.0
set BUILD_DIR=build
set INSTALL_PREFIX=%USERPROFILE%\.local

REM ========== COLORS (Windows 10+) ==========
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM ========== FUNCTIONS ==========
goto :main

:log_info
echo %BLUE%[INFO]%NC% %~1
goto :eof

:log_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:log_warn
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:log_error
echo %RED%[ERROR]%NC% %~1
goto :eof

:print_banner
echo.
echo ================================================================
echo   %PROJECT_NAME% v%VERSION% Build System (Windows)
echo ================================================================
echo.
goto :eof

:check_dependencies
call :log_info "Checking dependencies..."

where cmake >nul 2>&1
if errorlevel 1 (
    call :log_error "cmake not found"
    echo Install CMake from: https://cmake.org/download/
    exit /b 1
)

where cl >nul 2>&1
if errorlevel 1 (
    where g++ >nul 2>&1
    if errorlevel 1 (
        call :log_error "No C++ compiler found (MSVC or MinGW)"
        echo Install Visual Studio or MinGW-w64
        exit /b 1
    )
    set COMPILER=MinGW
) else (
    set COMPILER=MSVC
)

call :log_success "All required dependencies found (Compiler: %COMPILER%)"
goto :eof

:detect_features
call :log_info "Detecting optional features..."
set HAVE_CAIRO=OFF
set HAVE_OPENGL=OFF
set HAVE_CUDA=OFF

where nvcc >nul 2>&1
if not errorlevel 1 (
    call :log_success "CUDA found (GPU acceleration available)"
    set HAVE_CUDA=ON
) else (
    call :log_warn "CUDA not found (GPU features disabled)"
)

goto :eof

:clean_build
call :log_info "Cleaning build directory..."
if exist "%BUILD_DIR%" rd /s /q "%BUILD_DIR%"
call :log_success "Build directory cleaned"
goto :eof

:configure_cmake
call :log_info "Configuring CMake..."

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"

if "%COMPILER%"=="MSVC" (
    cmake .. ^
        -G "Visual Studio 16 2019" ^
        -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
        -DBUILD_SHARED_LIBS=ON ^
        -DBUILD_EXAMPLES=ON ^
        -DBUILD_PLOTTING=ON ^
        -DWITH_GPU=%HAVE_CUDA%
) else (
    cmake .. ^
        -G "MinGW Makefiles" ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
        -DBUILD_SHARED_LIBS=ON ^
        -DBUILD_EXAMPLES=ON ^
        -DBUILD_PLOTTING=ON ^
        -DWITH_GPU=%HAVE_CUDA%
)

cd ..
call :log_success "CMake configuration complete"
goto :eof

:build_project
call :log_info "Building project..."

cd "%BUILD_DIR%"

if "%COMPILER%"=="MSVC" (
    cmake --build . --config Release
) else (
    mingw32-make -j%NUMBER_OF_PROCESSORS%
)

cd ..
call :log_success "Build complete"
goto :eof

:install_project
call :log_info "Installing to %INSTALL_PREFIX%..."

cd "%BUILD_DIR%"
cmake --install .
cd ..

call :log_success "Installation complete"
goto :eof

:create_package
call :log_info "Creating distribution package..."

cd "%BUILD_DIR%"
cpack
cd ..

call :log_success "Package created"
goto :eof

:show_summary
echo.
echo ================================================================
echo   Build Summary
echo ================================================================
echo.
echo Project:          %PROJECT_NAME% v%VERSION%
echo Build directory:  %BUILD_DIR%
echo Install prefix:   %INSTALL_PREFIX%
echo Compiler:         %COMPILER%
echo.
echo Features:
echo   CUDA:           %HAVE_CUDA%
echo.
echo Executables:
echo   mlab++.exe      Main interpreter
echo   mlab_pkg.exe    Package manager
echo.
echo Next steps:
echo   1. Add to PATH:  set PATH=%INSTALL_PREFIX%\bin;%%PATH%%
echo   2. Run demo:     mlab++ matlab_examples\basic_demo.m
echo   3. Install pkg:  mlab++ pkg install materials_smart
echo.
echo ================================================================
echo.
goto :eof

REM ========== MAIN ==========
:main
call :print_banner

set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=build

if "%COMMAND%"=="clean" (
    call :clean_build
    goto :end
)

if "%COMMAND%"=="configure" (
    call :check_dependencies
    call :detect_features
    call :clean_build
    call :configure_cmake
    goto :end
)

if "%COMMAND%"=="build" (
    call :check_dependencies
    call :detect_features
    call :configure_cmake
    call :build_project
    call :show_summary
    goto :end
)

if "%COMMAND%"=="install" (
    call :check_dependencies
    call :detect_features
    call :configure_cmake
    call :build_project
    call :install_project
    call :show_summary
    goto :end
)

if "%COMMAND%"=="package" (
    call :check_dependencies
    call :detect_features
    call :configure_cmake
    call :build_project
    call :create_package
    goto :end
)

if "%COMMAND%"=="all" (
    call :check_dependencies
    call :detect_features
    call :clean_build
    call :configure_cmake
    call :build_project
    call :install_project
    call :create_package
    call :show_summary
    goto :end
)

if "%COMMAND%"=="help" (
    echo Usage: build.bat [command]
    echo.
    echo Commands:
    echo   clean       Clean build directory
    echo   configure   Configure CMake
    echo   build       Build project (default)
    echo   install     Build and install
    echo   package     Create distribution package
    echo   all         Clean, build, install, package
    echo   help        Show this help
    echo.
    goto :end
)

call :log_error "Unknown command: %COMMAND%"
echo Run 'build.bat help' for usage
exit /b 1

:end
endlocal
