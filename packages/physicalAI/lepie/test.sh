#!/usr/bin/env bash
set -euo pipefail

echo "== LePIE package smoke test =="
echo -n "LePIE commit: "
cat /opt/lepie.commit

test -d "${LEPIE_HOME:-/opt/lepie}"
test -x "${LEPIE_BUILD:-/opt/lepie/build}/bin/llama-server"

echo
echo "== llama-server version =="
"${LEPIE_BUILD:-/opt/lepie/build}/bin/llama-server" --version || true

echo
echo "== CUDA linkage =="
if command -v ldd >/dev/null 2>&1; then
    ldd "${LEPIE_BUILD:-/opt/lepie/build}/bin/llama-server" | grep -Ei 'cuda|cudart|cublas' || true
fi

echo
echo "== Jetson release =="
if [ -r /etc/nv_tegra_release ]; then
    cat /etc/nv_tegra_release
fi

echo
echo "LePIE smoke test passed."
