#!/bin/bash
cd "$(dirname "$0")"

echo "Creating symbolic link for NeoVim"
mkdir -p ~/.vim
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s ~/.vim $XDG_CONFIG_HOME/nvim
# I HAVENT REALLY IRONED THIS OUT WITH DOTPHILE SYMLINKS
ln -s ~/.vimrc ~/.config/nvim/init.vim

# Install Vim-Plug
echo "Installing Vim-Plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install FZF
echo "Installing FZF"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
sudo ln -s ~/.fzf/bin/fzf /usr/local/bin/fzf
sudo ln -s ~/.fzf/bin/fzf-tmux /usr/local/bin/fzf-tmux

# Install Powerline fonts
echo "Installing Powerline fonts"
git submodule init
git submodule update
powerline-fonts/install.sh

echo ""
echo "To install Plug pluggins"
echo "    :PlugInstall (inside vim)"

pip install vim-vint
#pip install grip # or use brew?
