#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/bump_version.sh [major|minor|patch]

Examples:
  ./scripts/bump_version.sh patch
  ./scripts/bump_version.sh minor
  ./scripts/bump_version.sh major
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

level="$1"
if [[ "$level" != "major" && "$level" != "minor" && "$level" != "patch" ]]; then
  usage
  exit 1
fi

current_raw="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"
current_semver="${current_raw%%+*}"

IFS='.' read -r major minor patch <<<"$current_semver"
case "$level" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
esac

new_version="${major}.${minor}.${patch}+1"

python3 - "$new_version" <<'PY'
import pathlib
import re
import sys

new_version = sys.argv[1]
path = pathlib.Path("pubspec.yaml")
content = path.read_text(encoding="utf-8")
updated, count = re.subn(
    r"(?m)^version:\s*[0-9]+\.[0-9]+\.[0-9]+(?:\+[0-9]+)?\s*$",
    f"version: {new_version}",
    content,
)
if count == 0:
    raise SystemExit("No version field found in pubspec.yaml")
path.write_text(updated, encoding="utf-8")
print(new_version)
PY

echo ""
echo "Updated pubspec version -> ${new_version}"
echo "Next:"
echo "  1) git add pubspec.yaml"
echo "  2) git commit -m \"chore: bump version to ${new_version}\""
echo "  3) git tag v${new_version%%+*} && git push origin main --tags"
