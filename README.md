# Lab 2 — CPU profiling, AVX2 and energy

Independent educational experiment in C11: an element-wise 32-bit integer
transformation of two arrays. The same input and workload is used for both
compiled versions: GCC `-O0` and `-O3 -mavx2`.

## Quick start on Linux

```bash
sudo apt update
sudo apt install build-essential binutils time linux-perf git python3
bash scripts/build.sh
bash scripts/measure_performance.sh
git clone --depth 1 https://github.com/brendangregg/FlameGraph.git
bash scripts/make_flames.sh
```

If `linux-perf` is not available, find the perf package for your distro/kernel
(for example `linux-tools-$(uname -r)` on some Ubuntu releases).

If `/proc/sys/kernel/perf_event_paranoid` or the VM host blocks perf events,
stop and use an environment where the course permits profiling. Do not fabricate
an empty flame graph; root inside a VM cannot override host restrictions.

`results/` contains `time`, `perf stat`, `perf report`, assembly, and SVG outputs.
The two programs must print an identical checksum for the same arguments.

## Energy experiment on a Linux laptop running on battery

On a *physical Linux installation* with a battery exporting
`/sys/class/power_supply/BAT*/energy_now` (micro-watt-hours), unplug AC and run:

```bash
python3 scripts/measure_energy.py --rounds 3000 --idle-seconds 45 --repeat 3
```

This measures **total battery energy** in each trial, and **estimates extra
system energy associated with the program** after subtracting idle baseline.
It does not directly isolate the hardware energy of one process. Battery readings
do not normally pass through to VMware guests. Keep screen brightness, wireless
state, workload, and power mode constant for fair comparison.

See the accompanying step-by-step guide for screenshots, interpretation, and
Word report locations.
