# Quick Fix for WSL Line Ending Issues

## Problem
The `build_native.sh` script has Windows line endings (CRLF) which causes errors in bash:
```
-bash: ./build_native.sh: cannot execute: required file not found
$'\r': command not found
```

## Solution 1: Fix Line Endings (Recommended)

### From PowerShell:
```powershell
cd v0.3.0/powershell
$content = Get-Content "build_native.sh" -Raw
$content = $content -replace "`r`n", "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD/build_native.sh", $content, $utf8NoBom)
```

### From WSL/Linux:
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++/v0.3.0/powershell

# Method 1: Using sed
sed -i 's/\r$//' build_native.sh

# Method 2: Using dos2unix (if installed)
dos2unix build_native.sh

# Method 3: Using tr
tr -d '\r' < build_native.sh > build_native_fixed.sh
mv build_native_fixed.sh build_native.sh
chmod +x build_native.sh
```

## Solution 2: Run with Bash Directly

Instead of `./build_native.sh`, use:
```bash
bash build_native.sh
```

This works even with CRLF line endings (though it's not ideal).

## Solution 3: Quick One-Liner Fix

From your current WSL location:
```bash
sed -i 's/\r$//' build_native.sh && chmod +x build_native.sh && ./build_native.sh
```

## Verify Fix

Check for carriage returns:
```bash
cat -A build_native.sh | head -5
```

If you see `^M$` at end of lines = Windows endings (bad)  
If you see just `$` at end of lines = Unix endings (good)

## After Fix

Then proceed with build:
```bash
chmod +x build_native.sh
./build_native.sh
```

Expected output:
```
Building MatLabC++ C Bridge for PowerShell...
✓ Built: libmatlabcpp_c_bridge.so
-rwxr-xr-x 1 user user 24K Jan 23 14:30 libmatlabcpp_c_bridge.so
Native bridge ready!
```

## Prevention

To avoid this in future, configure git:
```bash
# In your WSL terminal
git config --global core.autocrlf input
```

This prevents git from converting LF to CRLF on checkout.
