#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/bump_version.sh [major|minor|patch|build] [--build-number N] [--dry-run]

Examples:
  ./scripts/bump_version.sh patch
  ./scripts/bump_version.sh minor
  ./scripts/bump_version.sh major
  ./scripts/bump_version.sh build
  ./scripts/bump_version.sh patch --build-number 2060671846
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

level="$1"
if [[ "$level" != "major" && "$level" != "minor" && "$level" != "patch" && "$level" != "build" ]]; then
  usage
  exit 1
fi

manual_build_number=""
dry_run="false"

shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-number)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --build-number"
        exit 1
      fi
      manual_build_number="$2"
      shift 2
      ;;
    --dry-run)
      dry_run="true"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

current_raw="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"
current_semver="${current_raw%%+*}"
if [[ "$current_raw" == *"+"* ]]; then
  current_build="${current_raw##*+}"
else
  current_build="0"
fi

if ! [[ "$current_build" =~ ^[0-9]+$ ]]; then
  echo "Invalid current build number in pubspec.yaml: ${current_build}"
  exit 1
fi

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
  build)
    ;;
esac

if [[ -n "$manual_build_number" ]]; then
  if ! [[ "$manual_build_number" =~ ^[0-9]+$ ]]; then
    echo "--build-number must be numeric"
    exit 1
  fi
  next_build="$manual_build_number"
else
  # EN: Increment build number by exactly one for deterministic local releases.
  # KO: 로컬 릴리스 번호를 예측 가능하게 유지하기 위해 정확히 +1 증가합니다.
  next_build="$((current_build + 1))"
fi

if (( next_build > 2100000000 )); then
  echo "Computed build number exceeds Android limit: ${next_build}"
  exit 1
fi

new_version="${major}.${minor}.${patch}+${next_build}"

if [[ "$dry_run" == "true" ]]; then
  echo "Current: ${current_raw}"
  echo "Next:    ${new_version}"
  exit 0
fi

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
echo "Previous pubspec version -> ${current_raw}"
echo "Next:"
echo "  1) git add pubspec.yaml"
echo "  2) git commit -m \"chore: bump version to ${new_version}\""
echo "  3) git tag v${new_version%%+*} && git push origin main --tags"
