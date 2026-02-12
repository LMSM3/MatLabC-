#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
DIST_DIR="${ROOT_DIR}/dist"

mkdir -p "${BUILD_DIR}" "${DIST_DIR}/bin" "${DIST_DIR}/include"

cd "${BUILD_DIR}"
if [ ! -f "CMakeCache.txt" ]; then
  echo "Configuring (Release)..."
  cmake "${ROOT_DIR}" -DCMAKE_BUILD_TYPE=Release -DMATLABCPP_NATIVE_ARCH=ON
fi

echo "Building (Release)..."
cmake --build . --config Release -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

# Copy binaries
if [ -f "${BUILD_DIR}/matlabcpp" ]; then
  cp "${BUILD_DIR}/matlabcpp" "${DIST_DIR}/bin/"
fi
if [ -f "${BUILD_DIR}/benchmark_inference" ]; then
  cp "${BUILD_DIR}/benchmark_inference" "${DIST_DIR}/bin/"
fi

# Copy headers (public)
rsync -a --delete "${ROOT_DIR}/include/" "${DIST_DIR}/include/"

# Copy key examples
mkdir -p "${DIST_DIR}/examples/cpp"
cp "${ROOT_DIR}/examples/cpp/demo_pipeline.cpp" "${DIST_DIR}/examples/cpp/" 2>/dev/null || true

cat <<EOF
==========================================
Install complete
Prefix: ${DIST_DIR}
Binaries: ${DIST_DIR}/bin
Headers: ${DIST_DIR}/include
Example: ${DIST_DIR}/examples/cpp/demo_pipeline.cpp
Run: ${DIST_DIR}/bin/matlabcpp
==========================================
EOF
