#!/bin/sh

# Fail this script if any command fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

IOS_PLIST_PATH="$CI_PRIMARY_REPOSITORY_PATH/ios/Runner/GoogleService-Info.plist"

decode_base64_to_file() {
  encoded="$1"
  output="$2"

  if printf '%s' "$encoded" | base64 --decode > "$output" 2>/dev/null; then
    return 0
  fi
  if printf '%s' "$encoded" | base64 -D > "$output" 2>/dev/null; then
    return 0
  fi
  if printf '%s' "$encoded" | base64 -d > "$output" 2>/dev/null; then
    return 0
  fi
  return 1
}

create_ios_google_service_info_plist() {
  if [ -f "$IOS_PLIST_PATH" ]; then
    echo "GoogleService-Info.plist already exists; skip generation."
    return 0
  fi

  mkdir -p "$(dirname "$IOS_PLIST_PATH")"

  if [ -n "${GOOGLE_SERVICE_INFO_PLIST:-}" ]; then
    printf '%s' "$GOOGLE_SERVICE_INFO_PLIST" > "$IOS_PLIST_PATH"
    echo "Generated GoogleService-Info.plist from GOOGLE_SERVICE_INFO_PLIST."
    return 0
  fi

  if [ -n "${GOOGLE_SERVICE_INFO_PLIST_B64:-}" ]; then
    if decode_base64_to_file "$GOOGLE_SERVICE_INFO_PLIST_B64" "$IOS_PLIST_PATH"; then
      echo "Generated GoogleService-Info.plist from GOOGLE_SERVICE_INFO_PLIST_B64."
      return 0
    fi
    echo "Failed to decode GOOGLE_SERVICE_INFO_PLIST_B64."
    exit 1
  fi

  echo "Missing GoogleService-Info.plist secret."
  echo "Set one of these Xcode Cloud secrets:"
  echo "  - GOOGLE_SERVICE_INFO_PLIST_B64 (recommended)"
  echo "  - GOOGLE_SERVICE_INFO_PLIST (raw plist content)"
  exit 1
}

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

create_ios_google_service_info_plist

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.
