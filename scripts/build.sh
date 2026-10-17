#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results

gcc -std=c11 -O0 -g -fno-omit-frame-pointer -Wall -Wextra \
    -o bench_O0 src/bench.c
gcc -std=c11 -O3 -mavx2 -g -fno-omit-frame-pointer -Wall -Wextra \
    -fopt-info-vec-optimized=results/vectorization.txt \
    -o bench_O3 src/bench.c

objdump -d -M intel bench_O0 > results/assembly_O0.txt
objdump -d -M intel bench_O3 > results/assembly_O3.txt

./bench_O0 4096 3 > results/sanity_O0.txt
./bench_O3 4096 3 > results/sanity_O3.txt
diff -u results/sanity_O0.txt results/sanity_O3.txt
printf 'Both builds produce the same small-test checksum.\n'
printf 'Inspect results/vectorization.txt and results/assembly_O3.txt.\n'
