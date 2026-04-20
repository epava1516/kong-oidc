#!/bin/bash
set -euo pipefail

. .env
. bin/_docker.sh

cleanup() {
  local exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml ps || true
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml logs --no-color || true
  fi

  ./bin/teardown-env.sh || true
  exit $exit_code
}

trap cleanup EXIT

./bin/build-env.sh
python3 ${INTEGRATION_PATH}/verify.py
