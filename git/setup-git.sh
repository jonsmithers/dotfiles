#!/bin/bash
cd "$(dirname "$0")"

git submodule init
git submodule update

ln -s `pwd`/diff-highlight /usr/local/bin/diff-highlight
