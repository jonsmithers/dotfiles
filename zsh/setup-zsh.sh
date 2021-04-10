#! /usr/bin/env bash
set -e
cd "$(dirname "$0")"
source ../_helpers.sh

if test -d "$HOME/.oh-my-zsh"; then
  echo -e " ${GREEN}✓${NORMAL} oh-my-zsh installed"
elif prompt " ${RED}✗${NORMAL} missing oh-my-zsh - install?"; then
  (
    export CHSH=no;
    export RUNZSH=no;
    echo CHSH=no RUNZSH=no
    echo_and_run sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  )
fi


if test -d ~/.config/zsh/zsh-autosuggestions; then
  echo -e " ${GREEN}✓${NORMAL} zsh-autosuggestions installed"
elif prompt " ${RED}✗${NORMAL} missing zsh-autosuggestions - install?"; then
  echo_and_run mkdir -p ~/.config/zsh
  echo_and_run git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/zsh-autosuggestions
else
  echo "Skipping zsh-autosuggestions installation"
fi
