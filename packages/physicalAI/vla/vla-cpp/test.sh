#!/usr/bin/env bash
set -euo pipefail

echo "== vla.cpp package smoke test =="
echo -n "vla.cpp commit: "
cat /opt/vla-cpp.commit

test -d "${VLA_CPP_HOME:-/opt/vla.cpp}"
test -x "${VLA_CPP_BUILD:-/opt/vla.cpp/build}/vla-cli"
test -x "${VLA_CPP_BUILD:-/opt/vla.cpp/build}/vla-server"
test -x "${VLA_CPP_BUILD:-/opt/vla.cpp/build}/vla-bench"

echo
echo "== vla.cpp binaries =="
"${VLA_CPP_BUILD:-/opt/vla.cpp/build}/vla-cli" --help >/dev/null
"${VLA_CPP_BUILD:-/opt/vla.cpp/build}/vla-server" --help >/dev/null
"${VLA_CPP_BUILD:-/opt/vla.cpp/build}/vla-bench" --help >/dev/null

echo
echo "== CUDA linkage =="
if command -v ldd >/dev/null 2>&1; then
    ldd "${VLA_CPP_BUILD:-/opt/vla.cpp/build}/vla-server" | grep -Ei 'cuda|cudart|cublas' || true
fi

echo
echo "== Jetson release =="
if [ -r /etc/nv_tegra_release ]; then
    cat /etc/nv_tegra_release
fi

echo
echo "vla.cpp smoke test passed."
