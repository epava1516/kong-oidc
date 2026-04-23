#!/bin/bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_docker.sh"

cd "${REPO_ROOT}"

(set -ex
  docker build \
    --build-arg KONG_BASE_TAG=${KONG_BASE_TAG} \
    --build-arg KONG_BASE_DIGEST=${KONG_BASE_DIGEST} \
    -t ${BUILD_IMG_NAME} \
    -f ${UNIT_PATH}/Dockerfile .

  container_id=$(docker create ${BUILD_IMG_NAME} /bin/bash test/unit/run.sh)
  docker start -a ${container_id}
  docker cp ${container_id}:/usr/local/kong-oidc/luacov.report.out ./luacov.report.out
  docker cp ${container_id}:/usr/local/kong-oidc/luacov.stats.out ./luacov.stats.out
  docker rm ${container_id}
)

echo "Done"
