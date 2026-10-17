
# Lab 2 — Performance Measurement and Analysis

Performance analysis of an original C11 program that repeatedly transforms arrays of 32-bit unsigned integers.

Two builds of the same source code are compared:
- `-O0`: no compiler optimization;
- `-O3 -mavx2`: compiler optimization with AVX2 enabled.

The experiments were conducted in Kali Linux running in VMware Workstation. Energy measurements were collected from the Windows 11 host.

## Build and performance measurement

Requirements: GCC, binutils, GNU time, Linux perf, Git and Python 3.

```bash
sudo apt update
sudo apt install build-essential binutils time linux-perf git python3

bash scripts/build.sh
bash scripts/measure_performance.sh
```

The performance workload uses 1,048,576 elements and 1,000 processing rounds.

The measurement script runs GNU time, `perf stat -d`, `perf record` and `perf report` for both builds.

## CPU FlameGraphs

After recording the performance profiles:

```bash
git clone --depth 1 https://github.com/brendangregg/FlameGraph.git
bash scripts/make_flames.sh
```

Generated graphs:
- `results/flame_O0.svg`
- `results/flame_O3.svg`

The repository also includes disassembled code for both builds and GCC vectorization diagnostics.

## Energy measurement

The benchmark runs in the Kali Linux virtual machine. Since battery energy information was unavailable inside the guest, power consumption was measured on the physical Windows 11 laptop using PowerShell.

On the Windows host, while running on battery:

```powershell
powershell -NoProfile -File .\scripts\log_battery.ps1 -DurationSeconds 600
```

The energy experiment uses 1,048,576 elements and 50,000 rounds for each build.

The recorded battery data is provided in:

`data/energy_final_20261017_175644.csv`

To reproduce the energy calculations on Windows:

```powershell
powershell -NoProfile -File .\scripts\analyze_energy.ps1
```

Total system energy is estimated using average discharge power and execution time:

`E_system ≈ P_system × t`

Additional energy associated with the benchmark is estimated by subtracting the idle baseline:

`E_program_estimate ≈ (P_system − P_idle) × t`

The idle baseline was approximately 9.97 W.

This is an indirect estimate of additional system energy, not a direct hardware measurement of an individual process. Background processes, virtualization and battery measurement resolution may affect the results.

## Main results

For 1,000 processing rounds:
- Execution time: 3.06 s (`-O0`) versus 0.90 s (`-O3`).
- Speedup: 3.40×.
- Recorded CPU cycles decreased by approximately 68.30%.

For 50,000 processing rounds:
- Execution time: 347.89 s versus 55.16 s.
- Total system energy: 4513.4 J versus 822.6 J.
- Estimated additional energy: 1044.4 J versus 272.6 J.

Some hardware performance counters were unreliable in the virtual machine and were excluded from interpretation.

## Laboratory report

The complete methodology, screenshots, measurement tables, assembly comparison and conclusions are available in:

`Lab2_Zlata_Dovbyk_Report.docx`
