#!/bin/bash
set -e
cd "$(dirname "$0")"
source ../_helpers.sh

BACK_DIR="$HOME/.config/vimbackup"

if [[ -d "$BACK_DIR" ]]; then
  echo -e " ${GREEN}✓${NORMAL} $BACK_DIR exists"
elif prompt " ${RED}✗${NORMAL} missing $BACK_DIR - create?"; then
  echo_and_run mkdir -p "$BACK_DIR"
fi
