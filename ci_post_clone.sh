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

  # Fallback: compose plist from discrete Firebase env vars.
  if [ -n "${FIREBASE_IOS_APP_ID:-}" ] && \
     [ -n "${FIREBASE_IOS_API_KEY:-}" ] && \
     [ -n "${FIREBASE_IOS_MESSAGING_SENDER_ID:-}" ] && \
     [ -n "${FIREBASE_IOS_PROJECT_ID:-}" ]; then
    cat > "$IOS_PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>API_KEY</key>
  <string>${FIREBASE_IOS_API_KEY}</string>
  <key>GCM_SENDER_ID</key>
  <string>${FIREBASE_IOS_MESSAGING_SENDER_ID}</string>
  <key>PLIST_VERSION</key>
  <string>1</string>
  <key>BUNDLE_ID</key>
  <string>${FIREBASE_IOS_BUNDLE_ID:-org.pyrimidines.girlsbandtabi}</string>
  <key>PROJECT_ID</key>
  <string>${FIREBASE_IOS_PROJECT_ID}</string>
  <key>STORAGE_BUCKET</key>
  <string>${FIREBASE_IOS_STORAGE_BUCKET:-}</string>
  <key>IS_ADS_ENABLED</key>
  <false/>
  <key>IS_ANALYTICS_ENABLED</key>
  <false/>
  <key>IS_APPINVITE_ENABLED</key>
  <true/>
  <key>IS_GCM_ENABLED</key>
  <true/>
  <key>IS_SIGNIN_ENABLED</key>
  <true/>
  <key>GOOGLE_APP_ID</key>
  <string>${FIREBASE_IOS_APP_ID}</string>
</dict>
</plist>
EOF
    echo "Generated GoogleService-Info.plist from FIREBASE_IOS_* variables."
    return 0
  fi

  # Last-resort placeholder so Xcode resource copy phase does not fail.
  # Runtime Firebase init will fallback to dart-define options when available.
  cat > "$IOS_PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>API_KEY</key>
  <string>CI_PLACEHOLDER</string>
  <key>GCM_SENDER_ID</key>
  <string>CI_PLACEHOLDER</string>
  <key>PLIST_VERSION</key>
  <string>1</string>
  <key>BUNDLE_ID</key>
  <string>org.pyrimidines.girlsbandtabi</string>
  <key>PROJECT_ID</key>
  <string>ci-placeholder</string>
  <key>IS_GCM_ENABLED</key>
  <true/>
  <key>GOOGLE_APP_ID</key>
  <string>CI_PLACEHOLDER</string>
</dict>
</plist>
EOF
  echo "Generated placeholder GoogleService-Info.plist for CI build stability."
}

create_ios_google_service_info_plist

flutter pub get
cd ios
pod install --repo-update
