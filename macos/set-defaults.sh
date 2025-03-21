#!/bin/bash
set -e
cd "$(dirname "$0")"

source ../_helpers.sh

if [[ "$(uname)" == "Darwin" ]]; then
  echo "Setting MacOS defaults"
  (
    set -x
    defaults write -g ApplePressAndHoldEnabled -bool false
    # defaults write com.apple.finder QuitMenuItem -bool true # let me quit Finder
  )

  echo "Reducing menubar spacing"
  (
    set -x
    defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6
    defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 3
  )
  # defaults -currentHost delete -globalDomain NSStatusItemSpacing
  # defaults -currentHost delete -globalDomain NSStatusItemSelectionPadding
else
  echo "Skipping macos defaults because this isn't macos"
fi
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# https://github.com/herrbischoff/awesome-osx-command-line/

# Disable press-and-hold for keys in favor of key repeat.
# I need this to use the vim plugin in sublime (Dec 2014)

# HOLMAN'S JUNK:
# Use AirDrop over every interface. srsly this should be a default.
# defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1
# Always open everything in Finder's list view. This is important.
# defaults write com.apple.Finder FXPreferredViewStyle Nlsv
# Show the ~/Library folder.
# chflags nohidden ~/Library
# Set a really fast key repeat.
# defaults write NSGlobalDomain KeyRepeat -int 0
# Set the Finder prefs for showing a few different volumes on the Desktop.
# defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
# defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Run the screensaver if we're in the bottom-left hot corner.
# defaults write com.apple.dock wvous-bl-corner -int 5
# defaults write com.apple.dock wvous-bl-modifier -int 0
# Hide Safari's bookmark bar.
# defaults write com.apple.Safari ShowFavoritesBar -bool false
# Set up Safari for development.
# defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
# defaults write com.apple.Safari IncludeDevelopMenu -bool true
# defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
# defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
# defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
