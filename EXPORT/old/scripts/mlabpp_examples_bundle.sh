#!/usr/bin/env bash
# mlabpp_examples_bundle.sh
#
# Self-extracting MATLAB/Octave demo installer for MatLabC++
#
# Install behavior:
#   This script unpacks bundled MATLAB/Octave demo files into:
#     <install_root>/examples/
#   Default install_root is the current working directory.
#
# Usage:
#   ./mlabpp_examples_bundle.sh [install_root]
#
# After install, run demos like:
#   mlab++ filename.m --visual --enableGPU --noerrorlogs --silentcli
#
# Features:
# - Single-file portable installer (base64 + tar.gz payload)
# - Automatic annotation of installed files
# - Safe self-delete from temp locations
# - Idempotent (can run multiple times)
#
# Notes:
# - Payload is base64+tar.gz for portability
# - Script self-deletes when executed from temp location (or if FORCE_SELF_DELETE=1)
# - All .m files get prepended with install notes

set -euo pipefail

INSTALL_ROOT="${1:-$(pwd)}"
EXAMPLES_DIR="${INSTALL_ROOT%/}/examples"
SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# Create examples directory
mkdir -p "$EXAMPLES_DIR"

# ========== PAYLOAD EXTRACTION ==========
# Payload is tar.gz archived then base64-encoded
# We decode -> tar extract into EXAMPLES_DIR
_payload_extract() {
  # shellcheck disable=SC2016
  awk 'BEGIN{p=0} /^__PAYLOAD_BELOW__$/ {p=1; next} {if(p) print}' "$SELF_PATH" \
    | base64 -d \
    | tar -xz -C "$EXAMPLES_DIR"
}

echo "Extracting MATLAB examples..."
_payload_extract

# ========== ANNOTATE INSTALLED FILES ==========
# Prepend install note comment to each .m file (idempotent)
INSTALL_NOTE="% ============================================================
% Installed by mlabpp_examples_bundle.sh
% Location: ${EXAMPLES_DIR}
% 
% Run with: mlab++ <file>.m --visual --enableGPU --noerrorlogs --silentcli
% ============================================================

"

echo "Annotating MATLAB files..."
for f in "$EXAMPLES_DIR"/*.m; do
  [[ -f "$f" ]] || continue

  # If it already contains our install marker, skip
  if grep -q "^% Installed by mlabpp_examples_bundle\.sh" "$f" 2>/dev/null; then
    continue
  fi

  tmp="$(mktemp)"
  printf "%s" "$INSTALL_NOTE" > "$tmp"
  cat "$f" >> "$tmp"
  mv "$tmp" "$f"
  echo "  ✓ $(basename "$f")"
done

# ========== SUCCESS MESSAGE ==========
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ MATLAB examples installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "  Install location: $EXAMPLES_DIR"
echo
echo "  Run examples with:"
echo "    cd $EXAMPLES_DIR"
echo "    mlab++ filename.m --visual --enableGPU --noerrorlogs --silentcli"
echo
echo "  Available demos:"
for f in "$EXAMPLES_DIR"/*.m; do
  [[ -f "$f" ]] && echo "    - $(basename "$f")"
done
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# ========== SELF-DELETE LOGIC ==========
# Default: self-delete only if running from temp location
# Override: FORCE_SELF_DELETE=1 to always self-delete
is_tempish() {
  case "$SELF_PATH" in
    /tmp/*|/var/tmp/*|/private/tmp/*|"$HOME"/AppData/Local/Temp/*|"$HOME"/tmp/*) 
      return 0 ;;
    *) 
      return 1 ;;
  esac
}

if [[ "${FORCE_SELF_DELETE:-0}" == "1" ]] || is_tempish; then
  # Only delete if it's a regular file (safety check)
  if [[ -f "$SELF_PATH" ]]; then
    echo "Self-deleting installer from temp location..."
    rm -f -- "$SELF_PATH" || true
  fi
fi

exit 0

__PAYLOAD_BELOW__
# Base64-encoded tar.gz payload will be appended here
# Generate with: scripts/generate_examples_bundle.sh
