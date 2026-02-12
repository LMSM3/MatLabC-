@echo off
REM setup_project.bat - Create project structure for Windows

echo Setting up MatLabC++ v0.3.0 project structure...
echo.

REM Create directories
if not exist src\core mkdir src\core
if not exist src\plotting mkdir src\plotting
if not exist src\package_manager mkdir src\package_manager
if not exist src\cli mkdir src\cli
if not exist include\matlabcpp\plotting mkdir include\matlabcpp\plotting
if not exist include\matlabcpp\package_manager mkdir include\matlabcpp\package_manager
if not exist examples mkdir examples
if not exist tests mkdir tests
if not exist build mkdir build

echo [OK] Directories created

REM Create main.cpp if not exists
if not exist src\main.cpp (
    echo #include ^<iostream^> > src\main.cpp
    echo #include ^<string^> >> src\main.cpp
    echo. >> src\main.cpp
    echo int main(int argc, char** argv^) { >> src\main.cpp
    echo     std::cout ^<^< "MatLabC++ v0.3.0\n"; >> src\main.cpp
    echo     if (argc ^> 1^) { >> src\main.cpp
    echo         std::string arg = argv[1]; >> src\main.cpp
    echo         if (arg == "--version"^) { >> src\main.cpp
    echo             std::cout ^<^< "MatLabC++ version 0.3.0\n"; >> src\main.cpp
    echo             return 0; >> src\main.cpp
    echo         } >> src\main.cpp
    echo     } >> src\main.cpp
    echo     std::cout ^<^< "Type 'help' for usage information\n"; >> src\main.cpp
    echo     return 0; >> src\main.cpp
    echo } >> src\main.cpp
)

REM Create stub source files
echo // Core stub > src\core\matrix.cpp
echo // Vector stub > src\core\vector.cpp
echo // Functions stub > src\core\functions.cpp
echo // Interpreter stub > src\core\interpreter.cpp
echo // CLI argument parser > src\cli\argument_parser.cpp
echo // CLI REPL > src\cli\repl.cpp
echo // 2D renderer stub > src\plotting\renderer_2d.cpp
echo // 3D renderer stub > src\plotting\renderer_3d.cpp
echo // Plot spec stub > src\plotting\plot_spec.cpp
echo // Style presets stub > src\plotting\style_presets.cpp
echo // Package database stub > src\package_manager\database.cpp
echo // Repository stub > src\package_manager\repository.cpp
echo // Resolver stub > src\package_manager\resolver.cpp
echo // Installer stub > src\package_manager\installer.cpp
echo // Capability registry stub > src\package_manager\capability_registry.cpp

echo [OK] Stub source files created
echo.
echo Project structure ready!
echo.
echo Next steps:
echo   1. Review created files
echo   2. Run: build.bat build
echo   3. Implement functionality in source files
echo.
pause
