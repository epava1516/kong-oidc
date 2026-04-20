#!/bin/bash

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${BIN_DIR}/.." && pwd)"

set -a
. "${REPO_ROOT}/.env"
set +a

_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose --env-file "${REPO_ROOT}/.env" "$@"
  else
    docker compose --env-file "${REPO_ROOT}/.env" "$@"
  fi
}
