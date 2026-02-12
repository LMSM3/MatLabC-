@echo off
REM mlc.cmd - MatLabC++ Short Alias Wrapper
REM Forwards all arguments to the main matlabcpp executable
REM Part of MatLabC++ v0.3.0 command-line integration
REM This is an OPTIONAL alias - only installed if user checks the option

setlocal
"%~dp0matlabcpp.exe" %*
