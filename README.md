# 4×4 FPGA Matrix Multiplier

Modular Verilog-2001 RTL for signed 4×4 matrix multiplication, with sequential MAC, four-MAC row-parallel, and registered 4×4 systolic architectures. The requested project report, board identity, and prior run reports were not present in the workspace. The implementation therefore follows the explicit task specifications; no report-dependent figures or board constraints are assumed.

## Project map

```text
rtl/common/      Shared signed MAC and result bank
rtl/sequential/  Single-MAC datapath and controller
rtl/parallel/    Four-MAC datapath and controller
rtl/systolic/    PE, skewed 4×4 array, and wave controller
rtl/top/         Architecture selection wrapper
sim/             Independent reference model and focused testbenches
docs/            Architecture, verification, performance, and limitations
```

Module responsibilities, dependencies, and the interface contract are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Test instructions are in [sim/README.md](sim/README.md). Audit outcomes are in [docs/VERIFICATION_REPORT.md](docs/VERIFICATION_REPORT.md), [docs/PERFORMANCE_COMPARISON.md](docs/PERFORMANCE_COMPARISON.md), and [docs/KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md).

## Common interface

All architecture modules use `clk`, synchronous active-high `reset`, one-cycle `start`, `busy`, one-cycle `done`, and `cycle_count`. Inputs are two 256-bit buses, with signed 16-bit element `(r,c)` at bit slice `[16*(4*r+c) +: 16]`. Results use a 640-bit bus with signed 40-bit element `(r,c)` at `[40*(4*r+c) +: 40]`. `cycle_count` counts processing clocks after accepted start, through output capture; input setup and post-completion observation are excluded.

At the top level, architecture `00` selects sequential, `01` parallel, and `10` systolic. `11` selects no engine and remains idle. Do not change architecture while an operation is active.

## Vivado

Create an RTL project, add every `.v` file in `rtl/` as design sources, and set `matrix_multiplier_top` as top. Add the reference model and one test top from `sim/` as simulation sources for behavioral simulation. No device, pin, or timing constraints are included: the FPGA board model and revision have not been supplied.

Behavioral simulation was run in EDA Playground using Icarus Verilog 12.0. The sequential, parallel, and systolic regressions, systolic dataflow check, and top-level integration test reported PASS. Local Vivado synthesis/implementation and physical hardware results are not available; see `docs/VERIFICATION_REPORT.md` for scope and limitations.
