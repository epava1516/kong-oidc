#!/bin/bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_docker.sh"

cd "${REPO_ROOT}"

(set -ex
  docker build \
    --build-arg KONG_BASE_TAG=${KONG_BASE_TAG} \
    -t ${BUILD_IMG_NAME} \
    -f ${UNIT_PATH}/Dockerfile .
  docker run --rm ${BUILD_IMG_NAME} /bin/bash test/unit/run.sh
)

echo "Done"
