#!/bin/bash
# Build native C bridge library for PowerShell P/Invoke

                        # OUTDATED OUTDATED OUTDATED 

set -euo pipefail

echo "Building MatLabC++ C Bridge for PowerShell..."

# Detect platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    EXT="so"
    PREFIX="lib"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    EXT="dylib"
    PREFIX="lib"
else
    echo "Unsupported platform: $OSTYPE"
    exit 1
fi

OUTPUT="${PREFIX}matlabcpp_c_bridge.${EXT}"

# Build shared library
gcc -shared -fPIC -O2 \
    -o "$OUTPUT" \
    matlabcpp_c_bridge.c \
    -I../include \
    -lm

echo "✓ Built: $OUTPUT"
ls -lh "$OUTPUT"

# Copy to bin directory if it exists
if [ -d "bin/Debug/net6.0" ]; then
    cp "$OUTPUT" bin/Debug/net6.0/
    echo "✓ Copied to bin/Debug/net6.0/"
fi

if [ -d "bin/Release/net6.0" ]; then
    cp "$OUTPUT" bin/Release/net6.0/
    echo "✓ Copied to bin/Release/net6.0/"
fi

echo ""
echo "Native bridge ready!"
