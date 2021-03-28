#!/bin/bash
set -e
cd "$(dirname "$0")"

source ../_helpers.sh

# curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
#

if [[ ! $(command -v fish) ]] && prompt "Install fish"; then
  if [ "$(uname)" == "Darwin" ]; then
    brew install fish
  else
    python -m webbrowser "https://fishshell.com/"
  fi
fi

# if [[ ! $(command -v autojump) ]] && prompt "Install autojump"; then
#   if [ "$(uname)" == "Darwin" ]; then
#     brew install autojump
#   elif [[ $(command -v dnf) ]]; then
#     dnf install autojump-fish
#   elif [[ $(command -v apt) ]]; then
#     echo autojump installation not implemented
#   fi
# fi
