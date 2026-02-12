#!/usr/bin/env bash
set -euo pipefail

# ASCII "pixel"
PX="██"
RST=$'\e[0m'

# -----------------------------
# 8-bit / 256-color square
# -----------------------------
square_8bit() {
  local color="${1:-46}"   # 0..255
  local w="${2:-16}"
  local h="${3:-8}"
  local bg
  bg=$'\e[48;5;'"${color}"'m'
  for ((y=0; y<h; y++)); do
    for ((x=0; x<w; x++)); do printf "%s%s" "$bg" "$PX"; done
    printf "%s\n" "$RST"
  done
}

# -----------------------------
# 32-bit-ish / Truecolor (24-bit RGB) square
# -----------------------------
square_truecolor() {
  local r="${1:-80}" g="${2:-180}" b="${3:-255}"  # 0..255
  local w="${4:-16}" h="${5:-8}"
  local bg
  bg=$'\e[48;2;'"${r}"';'"${g}"';'"${b}"'m'
  for ((y=0; y<h; y++)); do
    for ((x=0; x<w; x++)); do printf "%s%s" "$bg" "$PX"; done
    printf "%s\n" "$RST"
  done
}

# -----------------------------
# 32x38 grayscale columns (truecolor)
# 32 columns across, 38 rows tall
# Each column is a different gray level
# -----------------------------
grayscale_32x38() {
  local cols=32 rows=38
  for ((y=0; y<rows; y++)); do
    for ((x=0; x<cols; x++)); do
      # Map x=0..31 to gray=0..255
      local gray=$(( x * 255 / (cols-1) ))
      printf "\e[48;2;%d;%d;%dm%s" "$gray" "$gray" "$gray" "$PX"
    done
    printf "%s\n" "$RST"
  done
}

# -----------------------------
# 256x256 "attempt"
# This prints a huge 2D gradient: R = x, G = y, B = 0.
# Expect wrap, lag, scrolling, and regret.
# -----------------------------
gradient_256x256() {
  local size=256
  for ((y=0; y<size; y++)); do
    for ((x=0; x<size; x++)); do
      printf "\e[48;2;%d;%d;%dm%s" "$x" "$y" 0 "$PX"
    done
    printf "%s\n" "$RST"
  done
}

# -----------------------------
# Dispatch
# -----------------------------
case "${1:-}" in
  8bit)        square_8bit "${2:-46}" "${3:-16}" "${4:-8}" ;;
  truecolor)   square_truecolor "${2:-80}" "${3:-180}" "${4:-255}" "${5:-16}" "${6:-8}" ;;
  gray32x38)   grayscale_32x38 ;;
  256x256)     gradient_256x256 ;;
  *)
    cat <<'USAGE'
Usage:
  ./color_blocks.sh 8bit [color 0-255] [w] [h]
  ./color_blocks.sh truecolor [r] [g] [b] [w] [h]
  ./color_blocks.sh gray32x38
  ./color_blocks.sh 256x256
USAGE
    ;;
esac
