#!/bin/bash
cd "$(dirname "$0")"

git submodule init
git submodule update

if [ ! -d "~/bin/" ]; then
  mkdir ~/bin
fi

ln -s `pwd`/diff-highlight ~/bin/diff-highlight

if [ "$(uname)" == "Darwin" ]; then
  echo Installing git-number for Mac
  brew install git-number
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  echo Installing git-number for linux
  curl https://raw.githubusercontent.com/holygeek/git-number/master/git-id     > ~/bin/git-id
  curl https://raw.githubusercontent.com/holygeek/git-number/master/git-list   > ~/bin/git-list
  curl https://raw.githubusercontent.com/holygeek/git-number/master/git-number > ~/bin/git-number
  chmod +x ~/bin/git-id
  chmod +x ~/bin/git-list
  chmod +x ~/bin/git-number
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  echo not worth it
fi
