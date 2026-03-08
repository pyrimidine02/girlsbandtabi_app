#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/build_android_internal.sh [major|minor|patch|build]

Examples:
  ./scripts/build_android_internal.sh
  ./scripts/build_android_internal.sh build
  ./scripts/build_android_internal.sh patch
EOF
}

level="${1:-build}"
if [[ "$level" != "major" && "$level" != "minor" && "$level" != "patch" && "$level" != "build" ]]; then
  usage
  exit 1
fi

./scripts/bump_version.sh "$level"

flutter build appbundle --release

artifact_path="build/app/outputs/bundle/release/app-release.aab"
if [[ -f "$artifact_path" ]]; then
  echo ""
  echo "Built artifact: $artifact_path"
  ls -lh "$artifact_path"
else
  echo "Build finished but artifact not found at $artifact_path"
  exit 1
fi
