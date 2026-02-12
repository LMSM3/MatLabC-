#!/usr/bin/env bash
set -euo pipefail

PASTELLE_GREEN=$'\e[38;2;119;221;119m'
PASTELLE_RED=$'\e[38;2;255;105;97m'
NC=$'\e[0m'

g="${PASTELLE_GREEN}OK${NC}"
r="${PASTELLE_RED}X${NC}"

spin_pid=""

spinner_start() {
  echo -n "Loading "
  (
    while true; do
      for i in 1 2 3; do
        echo -n "."
        sleep 0.5
      done
      echo -ne "\b\b\b   \b\b\b"
    done
  ) &
  spin_pid="$!"
}

spinner_stop() {
  if [[ -n "${spin_pid}" ]] && kill -0 "${spin_pid}" 2>/dev/null; then
    kill "${spin_pid}" 2>/dev/null || true
    wait "${spin_pid}" 2>/dev/null || true
  fi
  echo ""  # newline after spinner
}

warm_sudo() {
  echo "Requesting sudo..."
  sudo -v
}

retry_twice_wait60() {
  # try once; if it fails wait 60s; try once more
  if "$@"; then
    return 0
  fi
  echo " ${r} (retry in 60s) ${NC}"
  sleep 60
  "$@"
}

echo "Detecting package manager... "
spinner_start

pm="none"
if command -v pacman >/dev/null 2>&1; then
  pm="pacman"
elif command -v apt >/dev/null 2>&1; then
  pm="apt"
elif command -v dnf >/dev/null 2>&1; then
  pm="dnf"
fi

spinner_stop

if [[ "$pm" == "none" ]]; then
  echo " ${r}X ${NC}"; sleep 0.02
  exit 1
fi

echo "→ Detected: $pm"
warm_sudo

if [[ "$pm" == "pacman" ]]; then
  retry_twice_wait60 sudo pacman -S --needed mesa glu glew glfw-x11 glm

elif [[ "$pm" == "apt" ]]; then
  retry_twice_wait60 sudo apt update
  retry_twice_wait60 sudo apt install -y \
    mesa-utils libgl1-mesa-dev libglu1-mesa-dev \
    libglew-dev libglfw3-dev libglm-dev

elif [[ "$pm" == "dnf" ]]; then
  retry_twice_wait60 sudo dnf install -y \
    mesa-libGL mesa-libGLU mesa-libGL-devel mesa-libGLU-devel \
    glew-devel glfw-devel glm-devel
fi

echo " ${g} ${NC}"; sleep 0.02
