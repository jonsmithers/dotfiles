#!/bin/bash
cd "$(dirname "$0")"

if [[ -z `which diff-hightlight 2> /dev/null` ]]; then 
  echo "Installing diff-highlight"
  sudo easy_install diff-highlight
else
  echo "diff-highlight already installed"
fi
# alternatively:
# ln -s `pwd`/diff-highlight ~/bin/diff-highlight

if [[ -z `which git-number 2> /dev/null` ]]; then 
  if [ "$(uname)" == "Darwin" ]; then
    echo Installing git-number for Mac
    brew install git-number
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo Installing git-number for linux
    mkdir -p ~/git/git-number
    git clone https://github.com/holygeek/git-number.git ~/git/git-number
    cd ~/git/git-number
    sudo make install
    cd -
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    echo Good luck installing git-number here
  fi
else
  echo "git-number already installed"
fi
