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

if test -d ~/.config/zsh/zsh-syntax-highlighting; then
  echo -e " ${GREEN}✓${NORMAL} zsh-syntax-highlighting installed"
elif prompt " ${RED}✗${NORMAL} missing zsh-syntax-highlighting - install?"; then
  echo_and_run mkdir -p ~/.config/zsh
  echo_and_run git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.config/zsh/zsh-syntax-highlighting
else
  echo "Skipping zsh-syntax-highlighting installation"
fi

if [[ -f "$HOME/.config/zsh/fzf-git.sh" ]]; then
  echo -e " ${GREEN}✓${NORMAL} fzf-git installed"
elif prompt " ${RED}✗${NORMAL} missing fzf-git - install?"; then
  echo_and_run mkdir -p ~/.config/zsh
  echo_and_run curl https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh > ~/.config/zsh/fzf-git.sh
else
  echo "Skipping fzf-git installation"
fi

power_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ -d "$power_dir" ]]; then
  echo -e " ${GREEN}✓${NORMAL} powerlevel10k installed"
elif prompt " ${RED}✗${NORMAL} missing powerlevel10k - install?"; then
  echo_and_run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$power_dir"
else
  echo "Skipping powerlevel10k installation"
fi
unset power_dir
