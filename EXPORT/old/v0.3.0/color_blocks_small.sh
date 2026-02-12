#!/usr/bin/env bash
set -euo pipefail

PX="██"
RST=$'\e[0m'

# 8-bit palette grid (classic 6x6x6 cube + some grays)
grid_8bit() {
  local cols="${1:-16}"
  local start="${2:-16}"   # 16..231 is the 6x6x6 cube
  local end="${3:-231}"

  local c="$start"
  while (( c <= end )); do
    for ((i=0; i<cols && c<=end; i++)); do
      printf "\e[48;5;%dm%3d%s" "$c" "$c" "$RST"
      printf " "
      ((c++))
    done
    printf "\n"
  done
}

# Truecolor (24-bit) small square with a simple gradient
grid_truecolor() {
  local w="${1:-16}"
  local h="${2:-8}"
  for ((y=0; y<h; y++)); do
    for ((x=0; x<w; x++)); do
      # gentle gradient
      local r=$(( x * 255 / (w-1) ))
      local g=$(( y * 255 / (h-1) ))
      local b=$(( (x+y) * 255 / (w+h-2) ))
      printf "\e[48;2;%d;%d;%dm%s" "$r" "$g" "$b" "$PX"
    done
    printf "%s\n" "$RST"
  done
}

# 32x38 grayscale columns (tiny but readable): 32 columns, 8 rows (repeat)
gray_cols_32() {
  local cols=32
  local rows="${1:-8}"
  for ((y=0; y<rows; y++)); do
    for ((x=0; x<cols; x++)); do
      local gray=$(( x * 255 / (cols-1) ))
      printf "\e[48;2;%d;%d;%dm%s" "$gray" "$gray" "$gray" "$PX"
    done
    printf "%s\n" "$RST"
  done
}

# "256x256" concept as a tiny 16x16 sample grid
# where each cell maps into the 256x256 space.
grid_256x256_mini() {
  local w="${1:-16}"
  local h="${2:-16}"
  for ((y=0; y<h; y++)); do
    for ((x=0; x<w; x++)); do
      local X=$(( x * 255 / (w-1) ))
      local Y=$(( y * 255 / (h-1) ))
      # encode 256x256 into color: R=X, G=Y, B=0
      printf "\e[48;2;%d;%d;%dm%s" "$X" "$Y" 0 "$PX"
    done
    printf "%s\n" "$RST"
  done
}

case "${1:-}" in
  8bit)      grid_8bit "${2:-16}" "${3:-16}" "${4:-231}" ;;
  truecolor) grid_truecolor "${2:-16}" "${3:-8}" ;;
  gray32)    gray_cols_32 "${2:-8}" ;;
  256mini)   grid_256x256_mini "${2:-16}" "${3:-16}" ;;
  *)
    cat <<'USAGE'
Usage:
  ./tinygrid.sh 8bit [cols] [start] [end]
  ./tinygrid.sh truecolor [w] [h]
  ./tinygrid.sh gray32 [rows]
  ./tinygrid.sh 256mini [w] [h]

Examples:
  ./tinygrid.sh 8bit
  ./tinygrid.sh truecolor 20 10
  ./tinygrid.sh gray32 6
  ./tinygrid.sh 256mini 16 16
USAGE
    ;;
esac
