#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results

command -v perf >/dev/null || {
    echo "perf missing: install the perf package appropriate for your distribution." >&2
    exit 1
}
[[ -x /usr/bin/time ]] || {
    echo "GNU time missing: sudo apt install time" >&2
    exit 1
}

ELEMENTS="${1:-1048576}"
ROUNDS="${2:-1000}"
for level in O0 O3; do
    program="./bench_${level}"
    echo "=== ${level}: GNU time ==="
    /usr/bin/time --verbose -o "results/time_${level}.txt" \
        "$program" "$ELEMENTS" "$ROUNDS" > "results/output_${level}.txt"
    echo "=== ${level}: perf stat ==="
    perf stat -d -o "results/stat_${level}.txt" -- \
        "$program" "$ELEMENTS" "$ROUNDS" > /dev/null
    echo "=== ${level}: perf record ==="
    perf record -F 99 -e cpu-clock --call-graph fp \
        -o "results/perf_${level}.data" -- \
        "$program" "$ELEMENTS" "$ROUNDS" > /dev/null
    perf report --stdio -i "results/perf_${level}.data" \
        --no-children --percent-limit 0.5 > "results/report_${level}.txt"
done

diff -u results/output_O0.txt results/output_O3.txt
echo 'Checksums match. Metrics and perf files are under results/.'
