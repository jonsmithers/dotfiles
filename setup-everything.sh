#!/bin/bash
source _helpers.sh
if prompt "Symlink dotfiles?"; then
  ./dotphile
fi
vim/setup-vim.sh
git/setup-git.sh
fish/setup-fish.sh
osx/set-defaults.sh
