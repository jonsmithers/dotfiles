#!/bin/bash
set -e
cd "$(dirname "$0")"
source ../_helpers.sh

if [[ $(command -v nvim) ]] && prompt "Symlink for NeoVim (not entirely ironed out)"; then
  echo "Creating symbolic link for NeoVim"
  # I HAVENT REALLY IRONED THIS OUT WITH DOTPHILE SYMLINKS
  mkdir -p ~/.vim
  mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
  ln -s ~/.vim "$XDG_CONFIG_HOME/nvim"
  ln -s ~/.vimrc ~/.config/nvim/init.vim
else
  echo "Skipping neovim symlinks"
fi

if prompt "Install Powerline fonts"; then
  echo "Installing Powerline fonts"
  git submodule init
  git submodule update
  powerline-fonts/install.sh
else
  echo "Skipping powerline"
fi

if [[ ! $(command -v vint) ]] && (prompt "Install vim-vint"); then
  echo_and_run sudo pip install vim-vint
else
  echo "Skipping vim-vint"
fi

if [[ ! $(command -v shellcheck) ]] && (prompt "Install shellcheck"); then
  if [[ $(command -v brew) ]]; then
    brew install shellcheck
  elif [[ $(command -v dnf) ]]; then
    sudo dnf install ShellCheck
  elif [[ $(command -v apt) ]]; then
    sudo apt install shellcheck
  else
    echo 'Not sure how to install shellcheck :-/'
  fi
else
  echo "Skipping shellcheck"
fi

# todo - install grip? pip install? use brew?

SWAP_DIR="$HOME/.config/vimswap" 
if [[ ! -d "$SWAP_DIR" ]]; then
  echo "Creating swap file directory"
  echo_and_run mkdir -p "$SWAP_DIR"
else
  echo "Swap file directory already exists"
fi
