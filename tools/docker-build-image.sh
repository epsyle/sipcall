#!/usr/bin/env bash
# tools/docker-build-image.sh
# Сборка Docker-образа sipcall из корня проекта.
#
# Использование:
#   cd tools/
#   ./docker-build-image.sh
#   либо явно:  docker build -t sipcall ../

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="sipcall"
IMAGE_TAG="latest"

echo "==> Building Docker image ${IMAGE_NAME}:${IMAGE_TAG} from ${PROJECT_DIR}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "${PROJECT_DIR}"

echo
echo "==> Resulting image:"
docker images "${IMAGE_NAME}"
