# Independent Verification and Audit Report

## Scope and evidence

Reviewed the available RTL and README, reference model, and simulation sources. The referenced project report, synthesis report, constraints, and board definition were absent. The user ran the suite in EDA Playground using Icarus Verilog 12.0 and shared passing logs. Local Vivado/XSim, Verilator, Questa, and Yosys were unavailable.

## Static findings and changes

The initial audit found delayed clear pulses could suppress the first product on a new output and controllers advanced their indices during the result-write bubble, suppressing the next output's first product. Both controllers now hold their indices through that bubble. Completion was also asserted before final output storage updated; sequential/parallel completion now waits for the final write. Systolic startup now has a dedicated clear-priming phase so the first wave product is not discarded; output capture aligns with the completion edge.

Subsequent EDA Playground simulation runs passed the directed regressions. These results do not establish synthesis, timing, or hardware correctness.

## Suite contents

- `sim/matrix_reference_model.v`: separate combinational 16-element signed reference calculation, no DUT internal signals.
- `sim/tb_architecture_checker.v` plus three focused wrappers: directed zero, identity, all-ones, signed mixed, alternating `-32768`/`32767`, seeded random, held start, reset during operation, repeated operations, full-result comparison, X/Z reduction check, timeout, done and busy release checks.
- `sim/tb_systolic_dataflow.v`: direct registered transfer checks on a horizontal and a vertical PE link, boundary skew checks for each row and column, full matrix comparison, and cycle-count expectation.
- `sim/tb_matrix_multiplier_top.v`: all three architecture selections through the top.

The checker observed 80 sequential cycles, 20 parallel cycles, and 11 systolic compute cycles. Latency in clocks from accepted start edge through visible completion is one clock longer because the start-accept edge is excluded from `cycle_count`.

## Verification status

| Component | Verification performed | Result | Remaining issues |
|---|---|---|---|
| Arithmetic widths and signed extension | RTL source inspection | PASS | Runtime arithmetic unverified |
| Sequential datapath/control | EDA Playground Icarus 12.0 regression; 9 counted cases, zero failures | PASS | Vivado simulation/synthesis not run |
| Parallel datapath/control | EDA Playground Icarus 12.0 regression; 9 counted cases, zero failures | PASS | Vivado simulation/synthesis not run |
| Systolic PE result/control | EDA Playground Icarus 12.0 regression; 9 counted cases, zero failures | PASS | Vivado simulation/synthesis not run |
| Systolic PE links and skew | EDA Playground Icarus 12.0 dataflow check, PASS at 11 cycles | PASS | Representative links checked, not all per-cycle PE operands |
| Independent reference model | Source independence inspection | PASS | Compile/run unverified |
| Top-level selection | EDA Playground Icarus 12.0 integration test, all selections PASS | PASS | One integration vector |
| Simulation regression | EDA Playground Icarus 12.0, all listed test tops PASS | PASS | Vivado-specific simulation not run |
| Synthesis and implementation | No synthesis tool or target device | NOT VERIFIED | Requires Vivado and exact FPGA part |
| Hardware demonstration | Not performed | NOT VERIFIED | Requires target board |
