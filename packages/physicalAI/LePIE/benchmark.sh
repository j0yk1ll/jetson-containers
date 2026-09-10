#!/usr/bin/env bash
set -euo pipefail

MODEL="${MODEL:-}"
MMPROJ="${MMPROJ:-}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8080}"
PI_MODEL="${PI_MODEL:-pi05}"
WARMUP="${WARMUP:-3}"
RUNS="${RUNS:-10}"
IMAGE1="${IMAGE1:-}"
IMAGE2="${IMAGE2:-}"
STATE="${STATE:-0,0,0,0,0,0,0,0}"
PROMPT="${PROMPT:-pick up the object and place it into the tray}"
SERVER="${LEPIE_BUILD:-/opt/lepie/build}/bin/llama-server"
OUT_DIR="${OUT_DIR:-/data/lepie-benchmarks}"
STAMP="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="${OUT_DIR}/${STAMP}"
SERVER_LOG="${RUN_DIR}/server.log"

if [[ -z "${MODEL}" || -z "${MMPROJ}" ]]; then
    echo "MODEL and MMPROJ are required" >&2
    exit 2
fi

mkdir -p "${RUN_DIR}"

cleanup() {
    if [[ -n "${SERVER_PID:-}" ]]; then
        kill "${SERVER_PID}" >/dev/null 2>&1 || true
        wait "${SERVER_PID}" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT INT TERM

PI_MODEL="${PI_MODEL}" "${SERVER}" \
    -m "${MODEL}" \
    --mmproj "${MMPROJ}" \
    -ngl 99 \
    --host "${HOST}" \
    --port "${PORT}" \
    >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!

BASE="http://${HOST}:${PORT}"

for _ in $(seq 1 120); do
    if curl -fsS "${BASE}/health" >/dev/null 2>&1; then
        break
    fi
    if ! kill -0 "${SERVER_PID}" >/dev/null 2>&1; then
        cat "${SERVER_LOG}" >&2
        exit 1
    fi
    sleep 1
done

curl -fsS -X POST "${BASE}/foreground/reset" >/dev/null

if [[ -n "${IMAGE1}" ]]; then
    curl -fsS -X POST "${BASE}/foreground/image" \
        -H 'Content-Type: application/json' \
        -d "$(python3 -c 'import json,sys; print(json.dumps({"path":sys.argv[1]}))' "${IMAGE1}")" >/dev/null
fi

if [[ -n "${IMAGE2}" ]]; then
    curl -fsS -X POST "${BASE}/foreground/image" \
        -H 'Content-Type: application/json' \
        -d "$(python3 -c 'import json,sys; print(json.dumps({"path":sys.argv[1]}))' "${IMAGE2}")" >/dev/null
fi

STATE_JSON="$(python3 -c 'import json,sys; print(json.dumps({"state":[float(x) for x in sys.argv[1].split(",") if x.strip()]}))' "${STATE}")"
curl -fsS -X PUT "${BASE}/foreground/state" \
    -H 'Content-Type: application/json' \
    -d "${STATE_JSON}" >/dev/null

python3 /opt/lepie-tools/benchmark.py \
    --url "${BASE}/foreground/infer" \
    --prompt "${PROMPT}" \
    --warmup "${WARMUP}" \
    --runs "${RUNS}" \
    --output "${RUN_DIR}/results.json"

{
    echo "timestamp=${STAMP}"
    echo "lepie_commit=$(cat /opt/lepie.commit)"
    echo "model=${MODEL}"
    echo "mmproj=${MMPROJ}"
    echo "pi_model=${PI_MODEL}"
    echo "warmup=${WARMUP}"
    echo "runs=${RUNS}"
    echo "uname=$(uname -a)"
    if [[ -r /etc/nv_tegra_release ]]; then
        echo "nv_tegra_release=$(tr '\n' ' ' </etc/nv_tegra_release)"
    fi
} > "${RUN_DIR}/environment.txt"

echo "Benchmark artifacts: ${RUN_DIR}"
