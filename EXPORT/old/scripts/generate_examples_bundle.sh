#!/usr/bin/env bash
# generate_examples_bundle.sh
#
# Generates a self-extracting MATLAB examples installer
# Because GUIs are for cowards, and we ship single executable files.
#
# Usage:
#   ./generate_examples_bundle.sh
#
# Input:
#   ./matlab_examples/*.m  (source demo files)
#   ./scripts/mlabpp_examples_bundle.sh (template installer)
#
# Output:
#   ./dist/mlabpp_examples_bundle.sh (self-extracting installer)
#
# How it works:
#   1. Takes template installer script
#   2. Archives matlab_examples/ into tar.gz
#   3. Encodes tar.gz as base64
#   4. Appends encoded payload to template
#   5. Result: Single portable executable

set -euo pipefail

# ========== CONFIG ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXAMPLES_SRC_DIR="$PROJECT_ROOT/matlab_examples"
TEMPLATE_SCRIPT="$SCRIPT_DIR/mlabpp_examples_bundle.sh"
OUT_DIR="$PROJECT_ROOT/dist"
OUT_FILE="$OUT_DIR/mlabpp_examples_bundle.sh"

# ========== VALIDATION ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Generating self-extracting MATLAB examples bundle"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

if [[ ! -d "$EXAMPLES_SRC_DIR" ]]; then
  echo "❌ ERROR: Source directory not found: $EXAMPLES_SRC_DIR"
  echo
  echo "Create it with:"
  echo "  mkdir -p $EXAMPLES_SRC_DIR"
  echo "  # Add your .m files to matlab_examples/"
  exit 1
fi

if [[ ! -f "$TEMPLATE_SCRIPT" ]]; then
  echo "❌ ERROR: Template installer not found: $TEMPLATE_SCRIPT"
  exit 1
fi

# Count .m files
M_FILE_COUNT=$(find "$EXAMPLES_SRC_DIR" -maxdepth 1 -name "*.m" -type f | wc -l)
if [[ "$M_FILE_COUNT" -eq 0 ]]; then
  echo "⚠️  WARNING: No .m files found in $EXAMPLES_SRC_DIR"
  echo
  echo "Add some MATLAB demo files before generating bundle!"
  exit 1
fi

echo "✓ Found $M_FILE_COUNT MATLAB demo file(s)"
echo "✓ Template: $TEMPLATE_SCRIPT"
echo

# ========== CREATE OUTPUT DIRECTORY ==========
mkdir -p "$OUT_DIR"

# ========== BUILD BUNDLE ==========
echo "Building self-extracting bundle..."
echo

# Copy template (everything up to __PAYLOAD_BELOW__)
awk '/^__PAYLOAD_BELOW__$/ {exit} {print}' "$TEMPLATE_SCRIPT" > "$OUT_FILE"
echo "__PAYLOAD_BELOW__" >> "$OUT_FILE"

# Create tar.gz, encode as base64, append to bundle
echo "  • Archiving examples..."
ARCHIVE_SIZE=$(tar -cz -C "$EXAMPLES_SRC_DIR" . | tee >(base64 >> "$OUT_FILE") | wc -c)

# Calculate final size
BUNDLE_SIZE=$(stat -f%z "$OUT_FILE" 2>/dev/null || stat -c%s "$OUT_FILE" 2>/dev/null)
BUNDLE_SIZE_KB=$((BUNDLE_SIZE / 1024))

# Make executable
chmod +x "$OUT_FILE"

# ========== SUCCESS ==========
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Self-extracting bundle created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "  Output: $OUT_FILE"
echo "  Size:   ${BUNDLE_SIZE_KB} KB"
echo "  Files:  $M_FILE_COUNT MATLAB demos"
echo
echo "Test installation:"
echo "  cd /tmp && $OUT_FILE"
echo
echo "Distribution:"
echo "  # Copy single file to target system"
echo "  scp $OUT_FILE user@remote:~/"
echo "  ssh user@remote './mlabpp_examples_bundle.sh'"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
