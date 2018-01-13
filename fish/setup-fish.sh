#!/bin/bash
cd "$(dirname "$0")"

# curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
#

source ../_helpers.sh
if [[ ! `command -v fzf` ]] && prompt "Install fzf"; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
else
  echo "Skipping fzf installation"
fi
