#!/bin/bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_docker.sh"

cd "${REPO_ROOT}"

cleanup() {
  local exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml ps || true
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml logs --no-color || true
  fi

  "${REPO_ROOT}/bin/teardown-env.sh" || true
  exit $exit_code
}

trap cleanup EXIT

"${REPO_ROOT}/bin/build-env.sh"
python3 ${INTEGRATION_PATH}/verify.py
