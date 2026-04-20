#!/bin/bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_docker.sh"
. "${REPO_ROOT}/${INTEGRATION_PATH}/_network_functions"

(export DISCOVERY_HOST="${DISCOVERY_HOST:-${IP:-}}"
  cd "${REPO_ROOT}"

  if [[ -z "${DISCOVERY_HOST}" ]]; then
    echo "Please set DISCOVERY_HOST or IP. Example: export DISCOVERY_HOST=keycloak or export IP=192.168.0.1"
    exit 1
  fi

  (set -x
    # Tear down environment if it is running
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml down --remove-orphans
    docker build --build-arg KONG_BASE_TAG=${KONG_BASE_TAG} -t ${BUILD_IMG_NAME}${KONG_TAG} -f ${INTEGRATION_PATH}/Dockerfile .
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml up -d kong-db kong-session-store
  )

  _wait_for_listener localhost:${KONG_DB_PORT}
  _wait_for_listener localhost:${KONG_SESSION_STORE_PORT}

  (set -x
    if ! _compose -f ${INTEGRATION_PATH}/docker-compose.yml run --rm kong kong migrations bootstrap; then
      _compose -f ${INTEGRATION_PATH}/docker-compose.yml logs --no-color kong || true
      exit 1
    fi

    _compose -f ${INTEGRATION_PATH}/docker-compose.yml up -d
  )

  if ! _wait_for_endpoint http://localhost:${KONG_HTTP_ADMIN_PORT} 60; then
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml logs --no-color kong || true
    exit 1
  fi

  if ! _wait_for_endpoint http://localhost:${KEYCLOAK_PORT} 60; then
    _compose -f ${INTEGRATION_PATH}/docker-compose.yml logs --no-color keycloak || true
    exit 1
  fi

  (set -x
    python3 ${INTEGRATION_PATH}/setup.py
  )
)
