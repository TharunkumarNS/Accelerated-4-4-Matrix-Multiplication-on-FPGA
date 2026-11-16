# Architecture and Interface

## Hierarchy

```text
matrix_multiplier_top
├── sequential_multiplier
│   ├── sequential_controller
│   ├── mac_unit
│   └── output_storage
├── parallel_multiplier
│   ├── parallel_controller
│   └── 4 × mac_unit
└── systolic_array
    ├── systolic_controller
    └── 4 × 4 processing_element
```

The top instantiates all three independent engines and gates `start` by selection. `mac_unit` is shared by both non-systolic arithmetic architectures. Systolic PEs retain their own accumulator and forwarding registers because these are part of the array's local dataflow. `output_storage` is used by the sequential result stream; parallel and systolic capture their row/fabric results locally.

## RTL files

- `rtl/common/mac_unit.v`: signed 16×16 multiply plus signed 40-bit add.
- `rtl/common/output_storage.v`: 16 independently addressed signed 40-bit result words.
- `rtl/sequential/sequential_controller.v`: row, column, term, result-write bubble, completion sequencing, and cycle count.
- `rtl/sequential/sequential_multiplier.v`: one reused MAC and serial result storage.
- `rtl/parallel/parallel_controller.v`: term and row sequencing, including inter-row write/clear bubbles.
- `rtl/parallel/parallel_multiplier.v`: four MACs calculate four output columns concurrently for a row.
- `rtl/systolic/processing_element.v`: registered A-right/B-down forwarding and local accumulation.
- `rtl/systolic/systolic_controller.v`: array clear priming, wave phases, drain, completion, and cycle count.
- `rtl/systolic/systolic_array.v`: generated sixteen PE fabric, skewed boundary operands, and result capture.
- `rtl/top/matrix_multiplier_top.v`: architecture mux and common external interface.

## Arithmetic and packing

Operands are signed two's-complement 16-bit words. Each `mac_unit` declares the multiplication result as signed 32-bit, then extends its sign bit by eight bits before adding to a signed 40-bit accumulator. PE multiplication follows the same width convention. The final products of four 16-bit signed terms fit in 34 signed bits, so 40-bit accumulators provide headroom. Result elements are not narrowed.

Inputs are row-major, least-significant element first: `A[r][c] = matrix_a[16*(4*r+c) +:16]`; B is packed identically. Result element C[r][c] occupies `result[40*(4*r+c) +:40]`.

## Dataflows

The sequential engine shares exactly one MAC across all sixteen outputs. It accumulates four terms, writes the completed result, clears the accumulator during the write bubble, and advances. Its planned schedule is 64 product clocks, 15 inter-output write/clear clocks, and one final write/completion clock.

The parallel engine contains four independent MAC instances. Each consumes the same A row term and a different B column term; four row passes produce the matrix. Its planned schedule is 16 product clocks, three inter-row write/clear clocks, and one final write/completion clock.

The systolic fabric contains sixteen PEs. A enters each row with a row-dependent phase offset and moves right through registered PE outputs. B enters each column with a column-dependent offset and moves down. PE(r,c) accepts products during phases `r+c` through `r+c+3`. A clear priming clock precedes the wave; phase 10 allows the latest product wave to drain and results are captured at completion.

## Control contract

Reset is synchronous active-high. `start` is accepted when idle. `busy` remains high through output capture; `done` pulses when the complete result is visible. Start while busy is ignored. Matrices must remain stable throughout an operation. `cycle_count` starts at zero on accepted start and includes engine processing, required inter-output writes, and final output capture, but excludes input loading and result retrieval.
