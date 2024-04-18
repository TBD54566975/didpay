#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Hermit using Homebrew
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
HOMEBREW_NO_INSTALL_CLEANUP=1 # disable homebrew's cleanup after installation.
brew install hermit

# Activate Hermit environment
./bin/hermit env --export > hermit_env.sh
source hermit_env.sh

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
just get

# Install CocoaPods using Homebrew.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

exit 0