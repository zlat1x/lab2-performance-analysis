#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

FLAME_DIR="${1:-FlameGraph}"
if [[ ! -f "${FLAME_DIR}/stackcollapse-perf.pl" || ! -f "${FLAME_DIR}/flamegraph.pl" ]]; then
    echo "Clone https://github.com/brendangregg/FlameGraph into ${FLAME_DIR} first." >&2
    exit 1
fi

for level in O0 O3; do
    perf script -i "results/perf_${level}.data" | \
        perl "${FLAME_DIR}/stackcollapse-perf.pl" \
        > "results/stacks_${level}.folded"
    perl "${FLAME_DIR}/flamegraph.pl" --width 1500 \
        --title "CPU FlameGraph - ${level}" \
        "results/stacks_${level}.folded" > "results/flame_${level}.svg"
done
echo 'Open results/flame_O0.svg and results/flame_O3.svg in a browser.'
