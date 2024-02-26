#! /usr/bin/env bash
set -e
cd "$(dirname "$0")"
source ../_helpers.sh

if grep --quiet '^export KITTY_RC_PASSWORD=' < ~/.zshenv; then
  echo -e " ${GREEN}✓${NORMAL} KITTY_RC_PASSWORD is set"
elif prompt " ${RED}✗${NORMAL} set KITTY_RC_PASSWORD?"; then
  echo -n 'password› '
  read -s -r password
  echo "export KITTY_RC_PASSWORD='$password'" >> ~/.zshenv
  echo "remote_control_password '$password'" >> ~/.config/kitty/profile.conf
  echo "allow_remote_control password" >> ~/.config/kitty/profile.conf
  unset password
fi

fzfdocker_dir="$HOME/.config/zsh/fzf-docker"
if [[ -d "$fzfdocker_dir" ]]; then
  echo -e " ${GREEN}✓${NORMAL} fzf-docker installed"
elif prompt " ${RED}✗${NORMAL} missing fzf-docker - install?"; then
  echo_and_run git clone https://github.com/pierpo/fzf-docker "$fzfdocker_dir"
else
  echo "Skipping fzf-docker installation"
fi
