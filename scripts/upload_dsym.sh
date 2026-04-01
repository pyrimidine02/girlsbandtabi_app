#!/bin/bash
# EN: Manual Firebase Crashlytics dSYM upload script.
#     Use this after `flutter build ios --release` or after downloading dSYMs
#     from App Store Connect (Organizer → Archives → Download dSYMs).
# KO: Firebase Crashlytics dSYM 수동 업로드 스크립트.
#     `flutter build ios --release` 이후 또는 App Store Connect
#     (Organizer → Archives → dSYMs 다운로드)에서 받은 dSYM을 업로드할 때 사용합니다.
#
# Usage:
#   # Upload all dSYMs in a folder:
#   ./scripts/upload_dsym.sh /path/to/dSYMs/folder
#
#   # Upload a specific .dSYM file:
#   ./scripts/upload_dsym.sh /path/to/Runner.app.dSYM
#
# Requirements:
#   - Run `flutter pub get` and `pod install` (ios/) before using this script.
#   - GoogleService-Info.plist must exist at ios/Runner/GoogleService-Info.plist.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GSP="${REPO_ROOT}/ios/Runner/GoogleService-Info.plist"
UPLOAD_BIN="${REPO_ROOT}/ios/Pods/FirebaseCrashlytics/upload-symbols"

if [ ! -f "$GSP" ]; then
  echo "ERROR: GoogleService-Info.plist not found at ${GSP}" >&2
  exit 1
fi

if [ ! -x "$UPLOAD_BIN" ]; then
  echo "ERROR: upload-symbols binary not found at ${UPLOAD_BIN}" >&2
  echo "       Run 'cd ios && pod install' first." >&2
  exit 1
fi

DSYM_PATH="${1:-}"
if [ -z "$DSYM_PATH" ]; then
  echo "Usage: $0 <path-to-dSYM-file-or-folder>" >&2
  exit 1
fi

echo "Uploading dSYMs from: ${DSYM_PATH}"
"$UPLOAD_BIN" -gsp "$GSP" -p ios "$DSYM_PATH"
echo "Done."
