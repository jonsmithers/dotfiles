#!/bin/bash
source _helpers.sh
if prompt "Symlink dotfiles?"; then
  if [[ $(python --version 2>&1) =~ ^Python\ 3\. ]]; then
    ./dotphile3
  else
    ./dotphile
  fi
fi
vim/setup-vim.sh
git/setup-git.sh
fish/setup-fish.sh
osx/set-defaults.sh
