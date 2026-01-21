#!/bin/bash

set -euo pipefail

GOST_BIN=${GOST_BIN:-./gost}
GOST_ARGS=${GOST_ARGS:-"-C gost.yaml --api :8001"}
OUT_FILE=${OUT_FILE:-gost.out}
PIDFILE=${PIDFILE:-watchdog.pid}
RESTART_DELAY_SEC=${RESTART_DELAY_SEC:-5}

if [[ -f "${PIDFILE}" ]]; then
  old_pid="$(cat "${PIDFILE}" || true)"
  if [[ -n "${old_pid}" ]] && kill -0 "${old_pid}" 2>/dev/null; then
    exit 0
  fi
fi

echo "$$" > "${PIDFILE}"

cleanup() {
  rm -f "${PIDFILE}" || true
  pkill -x gost 2>/dev/null || true
}

trap cleanup EXIT INT TERM

pkill -x gost 2>/dev/null || true

while true; do
  nohup ${GOST_BIN} ${GOST_ARGS} >> "${OUT_FILE}" 2>&1 < /dev/null &
  child_pid=$!
  wait "${child_pid}" || true
  sleep "${RESTART_DELAY_SEC}"
done