#!/bin/bash

set -euo pipefail

GOST_BIN=${GOST_BIN:-./gost}
GOST_ARGS=${GOST_ARGS:-"-C gost.yaml --api :8001"}
OUT_FILE=${OUT_FILE:-gost.out}
RESTART_DELAY_SEC=${RESTART_DELAY_SEC:-5}

script_name="$(basename "$0")"
for pid in $(pgrep -f "${script_name}" 2>/dev/null || true); do
  if [[ "${pid}" != "$$" ]]; then
    kill "${pid}" 2>/dev/null || true
  fi
done

cleanup() {
  pkill -x gost 2>/dev/null || true
}

trap cleanup EXIT INT TERM

pkill -x gost 2>/dev/null || true

while true; do
  ${GOST_BIN} ${GOST_ARGS} >> "${OUT_FILE}" 2>&1 < /dev/null || true
  sleep "${RESTART_DELAY_SEC}"
done