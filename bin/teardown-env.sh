#!/bin/bash
set -euo pipefail

. .env
. bin/_docker.sh

_compose -f ${INTEGRATION_PATH}/docker-compose.yml down --remove-orphans --volumes
