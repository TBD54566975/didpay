#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods
brew install hermit

# Execute the command and store the output in a variable
output=$(./bin/hermit env)

# Process each line of the output
while IFS= read -r line; do
  # Check if the line contains an environment variable assignment
  if [[ $line =~ ^([A-Z_]+)=(.*)$ ]]; then
    # Extract the variable name and value
    var_name="${BASH_REMATCH[1]}"
    var_value="${BASH_REMATCH[2]}"
    
    # Set the environment variable
    export "$var_name"="$var_value"
  fi
done <<< "$output"

# activate hermit
. ./bin/activate-hermit

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
just get 

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

exit 0
