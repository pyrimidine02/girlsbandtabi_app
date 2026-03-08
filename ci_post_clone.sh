#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_PLIST_PATH="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"

decode_base64_to_file() {
  local encoded="$1"
  local output="$2"

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

  # Preferred: raw plist secret (full file content).
  if [ -n "${GOOGLE_SERVICE_INFO_PLIST:-}" ]; then
    printf '%s' "$GOOGLE_SERVICE_INFO_PLIST" > "$IOS_PLIST_PATH"
    echo "Generated GoogleService-Info.plist from GOOGLE_SERVICE_INFO_PLIST."
    return 0
  fi

  # Alternative: base64-encoded full plist.
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

create_ios_google_service_info_plist

flutter pub get
cd ios
pod install --repo-update
