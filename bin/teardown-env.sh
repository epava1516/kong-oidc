#!/bin/bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_docker.sh"

cd "${REPO_ROOT}"

_compose -f ${INTEGRATION_PATH}/docker-compose.yml down --remove-orphans --volumes
