#!/usr/bin/env bash
# tools/docker-run-container.sh
# Запуск Docker-контейнера sipcall.
#
# Использование:
#   cd tools/
#   ./docker-run-container.sh
#
# Примечания:
#   --network host     — контейнер использует сетевой стек хоста;
#                        порты 5060 и 8080 доступны снаружи без -p.
#   -e TZ=...          — таймзона для корректных timestamp в логах.
#   --rm               — удалить контейнер после остановки.
#   -it                — интерактивный режим с TTY (нужно для Eshell).

set -euo pipefail

IMAGE_NAME="sipcall:latest"
TZ="${TZ:-Asia/Novosibirsk}"

echo "==> Running container from image ${IMAGE_NAME}"
echo "    Time zone: ${TZ}"
echo "    Network:   host (порты 5060/udp, 5060/tcp, 8080/tcp доступны напрямую)"
echo
echo "    Внутри Eshell выполните:"
echo "      application:which_applications().   %% список запущенных приложений"
echo "      sipcall_registry:list().            %% список известных URI"
echo "      supervisor:which_children(sipcall_sup)."
echo

docker run --network host \
           -e TZ="${TZ}" \
           -it --rm \
           "${IMAGE_NAME}"
