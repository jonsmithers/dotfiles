#!/bin/bash
set -e
cd "$(dirname "$0")"
source ../_helpers.sh

# if prompt "Install Powerline fonts"; then
#   echo "Installing Powerline fonts"
#   git submodule init
#   git submodule update
#   powerline-fonts/install.sh
# else
#   echo "Skipping powerline"
# fi

if [[ ! $(command -v vint) ]] && (prompt "Install vim-vint"); then
  echo_and_run sudo pip install vim-vint
else
  echo "Skipping vim-vint"
fi

# SWAP_DIR="$HOME/.config/vimswap"
BACK_DIR="$HOME/.config/vimbackup"

if [[ ! -d "$BACK_DIR" ]] && (prompt "Create vim backup directory"); then
  echo "Creating vim backup file directory"
  echo_and_run mkdir -p "$BACK_DIR"
else
  echo "Skipping creation of vim backup file directory"
fi
