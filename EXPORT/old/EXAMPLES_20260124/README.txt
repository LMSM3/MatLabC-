EXAMPLES_20260124
================

MatLabC++ MATLAB Version Detection Test Suite

This directory contains minimal MATLAB scripts to verify MATLAB version compatibility
and environment detection for the MatLabC++ bridge system.

Files:
------
- mlc_01_matlab_version_min.m  : Prints MATLAB version, release, and platform info
- mlc_02_matlab_env_min.m      : Prints environment details (desktop/headless, products, license)
- mlc_03_probe.c               : C probe stub for bridge testing

Usage:
------
Run in MATLAB:
  >> run('mlc_01_matlab_version_min.m')
  >> run('mlc_02_matlab_env_min.m')

Compile C probe:
  gcc mlc_03_probe.c -o mlc_03_probe
  ./mlc_03_probe

Purpose:
--------
Demonstrates that MatLabC++ exhibits characteristics compatible with MATLAB Version X.X.X
(awaiting testing)

Generated: 2026-01-24
