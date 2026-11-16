# Performance Comparison

## Measurement boundary

The RTL counter begins at zero on accepted `start`, counts engine clocks through final output capture, and excludes input loading and output retrieval. Clock latency from the accepted start edge to completion is `cycle_count + 1`. The values below were observed in EDA Playground with Icarus Verilog 12.0; they are simulation counts, not FPGA timing measurements.

| Architecture | MAC count | Schedule-derived cycles | Expected clock latency | Throughput after completion | Simulation status |
|---|---:|---:|---:|---|---|
| Sequential | 1 | 64 products + 15 write/clear bubbles + 1 final capture = 80 | 81 clocks | 1 matrix / 81 clocks (including accepted-start edge) | PASS |
| Parallel | 4 | 16 products + 3 write/clear bubbles + 1 final capture = 20 | 21 clocks | 1 matrix / 21 clocks | PASS |
| Systolic | 16 PEs | 11 phased compute/drain clocks | 12 clocks | 1 matrix / 12 clocks | PASS |

On the observed schedules, sequential-relative cycle speedup is 1×, 4×, and about 7.27× for sequential, parallel, and systolic respectively (80/20 and 80/11). These compare cycle counts only, not FPGA operating frequency.

The parallel engine trades four MAC datapaths for fewer cycles. The systolic engine uses sixteen local accumulators and forwarding registers to overlap products spatially; it has more arithmetic and state than the other engines. No DSP/LUT/FF/BRAM counts, maximum frequency, timing slack, or board throughput can be stated because synthesis and implementation were not run and the FPGA part is unspecified. Real execution time is `latency_clocks / achieved_clock_frequency`; a higher cycle speedup does not guarantee a proportional wall-clock speedup if the architectures achieve different clock frequencies.
