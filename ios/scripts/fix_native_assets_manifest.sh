#!/bin/sh
# EN: Patch iOS native-assets manifest entries that use a non-loadable
# EN: framework-relative path for objective_c.
# KO: iOS native-assets 매니페스트에서 objective_c 로딩 경로를
# KO: 실제 런타임 로더가 해석 가능한 경로로 보정합니다.

set -eu
(set -o pipefail) >/dev/null 2>&1 && set -o pipefail

MANIFEST_PATH="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/App.framework/flutter_assets/NativeAssetsManifest.json"

if [ ! -f "${MANIFEST_PATH}" ]; then
  echo "native-assets fix: manifest not found at ${MANIFEST_PATH}"
  exit 0
fi

if ! /usr/bin/grep -q 'objective_c.framework/objective_c' "${MANIFEST_PATH}"; then
  exit 0
fi

TMP_FILE="${MANIFEST_PATH}.tmp"
/usr/bin/sed 's#objective_c.framework/objective_c#@executable_path/Frameworks/objective_c.framework/objective_c#g' "${MANIFEST_PATH}" > "${TMP_FILE}"
/bin/mv "${TMP_FILE}" "${MANIFEST_PATH}"
echo "native-assets fix: patched objective_c path in NativeAssetsManifest.json"
