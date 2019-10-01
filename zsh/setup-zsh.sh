#! /usr/bin/env bash
set -e
cd "$(dirname "$0")"
source ../_helpers.sh

if [[ -z "$(command -v zsh)" ]] && prompt "Install zsh?"; then
  if [[ -n "$(command -v dnf)" ]]; then
    echo_and_run sudo dnf install zsh
  elif [[ -n "$(command -v brew)" ]]; then
    echo_and_run brew install zsh
  else 
    echo "${RED}Dunno how to install zsh"
    exit 1
  fi
else
  echo "Skipping zsh installation"
fi

if ! test -d "$HOME/.oh-my-zsh" && prompt "Install oh-my-zsh?"; then
  CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && {
    echo_and_run mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
  }
else
  echo "Skipping oh-my-zsh installation"
fi

if ! test -d ~/.config/zsh/zsh-autosuggestions && prompt "Install zsh-autosuggestions?"; then
  mkdir -p ~/.config/zsh
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/zsh-autosuggestions
else
  echo "Skipping zsh-autosuggestions installation"
fi
