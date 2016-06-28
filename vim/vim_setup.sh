# Install Vim-Plug

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install Vundle

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Tern Plugin Setup
echo "please run:"
echo ":   :PlugInstall (inside vim)"
echo "    cd ~/.vim/**/tern_for_vim;"
echo "    npm install"
