#!/bin/bash
cd "$(dirname "$0")"

source ../_helpers.sh

# curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
#

if [[ ! `command -v fish` ]] && prompt "Install fish"; then 
  if [ "$(uname)" == "Darwin" ]; then
    brew install fish
  else
    python -m webbrowser "https://fishshell.com/"
  fi
fi

source ../_helpers.sh
if [[ ! `command -v fzf` ]] && prompt "Install fzf"; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
else
  echo "Skipping fzf installation"
fi

if [[ ! `command -v rg` ]] && prompt "Install rg"; then
  if [ "$(uname)" == "Darwin" ]; then
    brew install ripgrep
  elif [[ `command -v dnf` ]]; then
    sudo dnf install ripgrep
  elif prompt "Download hardcoded 0.8.1 rg version for debian?"; then
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.8.1/ripgrep_0.8.1_amd64.deb
    sudo dpkg -i ripgrep_0.8.1_amd64.deb
  else
    python -m webbrowser "https://github.com/BurntSushi/ripgrep#installation"
  fi
fi
