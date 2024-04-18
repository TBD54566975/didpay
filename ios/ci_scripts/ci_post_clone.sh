#!/bin/bash

# Fail this script if any subcommand fails.
set -e

# Set the default execution directory to the root of the cloned repository.
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Check if Hermit is installed, and install it if necessary.
if [ ! -x "bin/hermit" ]; then
  # Create the bin directory if it doesn't exist.
  mkdir -p bin

  # Download the Hermit install script.
  curl -fsSL https://github.com/cashapp/hermit/releases/download/stable/install.sh -o bin/install-hermit.sh

  # Make the install script executable.
  chmod +x bin/install-hermit.sh

  # Run the Hermit install script.
  bin/install-hermit.sh
fi

# Activate the Hermit environment.
source bin/activate-hermit

# Enable caching of Flutter artifacts and dependencies.
if [ "$CACHE_ENABLED" = "true" ]; then
  flutter_cache_dir="$HOME/.flutter"
  cocoapods_cache_dir="$HOME/Library/Caches/CocoaPods"

  mkdir -p "$flutter_cache_dir" "$cocoapods_cache_dir"

  echo "Flutter cache directory: $flutter_cache_dir"
  echo "CocoaPods cache directory: $cocoapods_cache_dir"
fi

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
just get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

exit 0