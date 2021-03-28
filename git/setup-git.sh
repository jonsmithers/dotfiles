#!/bin/bash
set -e
cd "$(dirname "$0")"

source ../_helpers.sh

if [[ ! $(command -v diff-highlight) ]] && prompt "Install diff-highlight"; then
  echo "Installing diff-highlight"
  if [[ $(command -v easy_install) ]]; then
    sudo easy_install diff-highlight
  else
    echo "CANT INSTALL DIFF-HIGHLIGHT WITHOUT EASY_INSTALL"
  fi
else
  echo "Skipping diff-highlight"
fi
# alternatively:
# ln -s `pwd`/diff-highlight ~/bin/diff-highlight

