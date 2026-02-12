@echo off
REM mlcpp.cmd - MatLabC++ Primary Command Wrapper
REM Forwards all arguments to the main matlabcpp executable
REM Part of MatLabC++ v0.3.0 command-line integration

setlocal
"%~dp0matlabcpp.exe" %*
