#!/bin/bash
set -e
cd "$(dirname "$0")"

source ../_helpers.sh

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This isn't macos"
  return 1
fi

# https://medium.com/@mailmuellerkai/the-annoyance-of-missing-press-and-hold-in-vim-plugin-on-mac-for-vs-code-897d639f00f5
echo "Disable press and hold for vscode"
( set -x; defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false )

echo "Reduce menubar spacing"
(
  set -x
  defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6
  defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 3
)

# https://github.com/herrbischoff/awesome-osx-command-line/
