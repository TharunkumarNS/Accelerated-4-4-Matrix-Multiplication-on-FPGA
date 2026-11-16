# Verification suite

`matrix_reference_model.v` independently calculates all sixteen outputs with signed 16×16 products accumulated in signed 40-bit values. Each architecture test wrapper runs the common vectors in `tb_architecture_checker.v`. Run each top separately because each test ends the simulation with `$finish`.

## Test coverage

- Zero, identity, all-ones, mixed-sign, alternating signed-limit (`-32768`, `32767`), reproducible `$random(seed)`, and back-to-back input cases.
- Reset and idle controls, busy assertion, done timeout, start held high, reset during computation, and result X/Z checks.
- Every result element is compared against the independent reference model.
- `tb_systolic_dataflow.v` additionally checks registered A transfer from PE(0,0) to PE(0,1), registered B transfer from PE(0,0) to PE(1,0), the full result, and the implemented computation cycle count.
- `tb_matrix_multiplier_top.v` runs all three architecture selections through the integration top.

## Cycle interval

The DUT `cycle_count` begins at zero when an accepted start is sampled and increments on each active processing clock. It excludes loading the input buses and observing the output. Sequential and parallel designs use four MAC steps per output and a final result-write/done cycle; systolic uses its skewed wave and drain schedule. The count is the design's reported active interval, not a board-level latency measurement. No performance numbers are reported until a simulator is run.

## Running

Add all `rtl/**/*.v` and `sim/matrix_reference_model.v`, `sim/tb_architecture_checker.v`, plus exactly one architecture wrapper to the simulator. Set that wrapper as simulation top. For systolic dataflow, use `tb_systolic_dataflow` as the top instead. For integration, include `tb_matrix_multiplier_top.v` and use `tb_matrix_multiplier_top` as top. In Vivado use **Run Simulation → Run Behavioral Simulation**.

The test suite has not been executed in this environment because no Icarus Verilog, Verilator, Questa (`vsim`), Vivado/XSim, or Yosys executable is available. Simulation output and PASS claims are therefore intentionally absent.

## Known coverage limits

The tests are fixed at 4×4 and do not test optional UART, board pins, timing constraints, or synthesis resource/timing estimates. The dataflow test observes representative horizontal and vertical links directly and the independent output model exercises every PE's accumulation; it does not dump a per-cycle trace of all sixteen PE operands.
