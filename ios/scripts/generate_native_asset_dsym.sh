#!/bin/sh
# EN: Generate missing dSYM for native-asset frameworks (objective_c.framework)
# EN: and copy it into archive dSYMs so App Store validation passes.
# KO: native asset 프레임워크(objective_c.framework)의 누락 dSYM을 생성하고
# KO: 아카이브 dSYMs 폴더로 복사해 App Store 검증 오류를 방지합니다.

set -eu
(set -o pipefail) >/dev/null 2>&1 && set -o pipefail

FRAMEWORK_PATH="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/objective_c.framework"
BINARY_PATH="${FRAMEWORK_PATH}/objective_c"
DSYM_NAME="objective_c.framework.dSYM"
DSYM_PATH="${DWARF_DSYM_FOLDER_PATH}/${DSYM_NAME}"

if [ ! -f "${BINARY_PATH}" ]; then
  echo "native-asset dSYM: objective_c.framework not found at ${FRAMEWORK_PATH}"
  exit 0
fi

if [ ! -d "${DSYM_PATH}" ]; then
  echo "native-asset dSYM: generating ${DSYM_NAME}"
  /usr/bin/dsymutil "${BINARY_PATH}" -o "${DSYM_PATH}"
fi

# EN: Ensure archive includes the generated framework dSYM.
# KO: 생성한 framework dSYM을 archive 결과물에도 포함합니다.
if [ -n "${ARCHIVE_DSYMS_PATH:-}" ]; then
  mkdir -p "${ARCHIVE_DSYMS_PATH}"
  /usr/bin/rsync -a "${DSYM_PATH}" "${ARCHIVE_DSYMS_PATH}/"
  echo "native-asset dSYM: copied ${DSYM_NAME} -> ${ARCHIVE_DSYMS_PATH}"
fi
