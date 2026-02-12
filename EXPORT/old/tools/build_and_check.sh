#!/usr/bin/env bash
# MatLabC++ - Robust Build & Version Check Script
# tools/build_and_check.sh
#
# Safely builds the project and verifies the executable.
# Works with single-config (Makefile, Ninja) and multi-config (VS, Ninja Multi-Config) generators.
#
# Usage:
#   ./tools/build_and_check.sh
#   BUILD_DIR=out CONFIG=Debug TARGET=mlab++ ./tools/build_and_check.sh

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ========== CONFIG (override via env vars) ==========
: "${BUILD_DIR:=build}"
: "${CONFIG:=Release}"          # For multi-config generators (Ninja Multi-Config, Visual Studio)
: "${TARGET:=mlab++}"
: "${EXE_PATH:=./${BUILD_DIR}/${TARGET}}"

# ========== HELPERS ==========
die() { 
    echo "ERROR: $*" >&2
    exit 1
}

# ========== DETECT PARALLELISM ==========
# Choose a parallelism value that exists on most systems
if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"
elif command -v sysctl >/dev/null 2>&1; then
    JOBS="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
else
    JOBS=4
fi

# ========== CONFIGURE ==========
echo "--- Configuring (if needed) ---"
echo "  Build directory: ${BUILD_DIR}"
echo "  Configuration: ${CONFIG}"
echo "  Target: ${TARGET}"
echo "  Parallel jobs: ${JOBS}"
echo ""

# Safe to call repeatedly; does nothing if already configured with same settings.
cmake -S . -B "${BUILD_DIR}"

# ========== BUILD ==========
echo ""
echo "--- Building target '${TARGET}' with -j${JOBS} ---"
# For single-config generators, CONFIG is ignored harmlessly.
cmake --build "${BUILD_DIR}" -j "${JOBS}" --config "${CONFIG}" --target "${TARGET}"

# ========== RESOLVE EXECUTABLE PATH ==========
# Multi-config generators place binaries in build/Release/, build/Debug/, etc.
# Single-config generators place them directly in build/
if [[ ! -x "${EXE_PATH}" && -x "./${BUILD_DIR}/${CONFIG}/${TARGET}" ]]; then
    EXE_PATH="./${BUILD_DIR}/${CONFIG}/${TARGET}"
fi

[[ -x "${EXE_PATH}" ]] || die "Built executable not found or not executable: ${EXE_PATH}"

# ========== VERIFY ==========
echo ""
echo "--- Build successful! ---"
echo "  Executable: ${EXE_PATH}"
echo ""
echo "--- Running version check ---"
"${EXE_PATH}" --version

echo ""
echo "--- Success! Ready to use ---"
echo "  Run interactively: ${EXE_PATH}"
echo "  Show help: ${EXE_PATH} --help"
