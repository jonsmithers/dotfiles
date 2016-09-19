#!/bin/bash
cd "$(dirname "$0")"

curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
