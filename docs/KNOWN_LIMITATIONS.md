# Known Limitations

- The report referenced by the project request is absent; requirements and comparisons could not be cross-checked against it.
- EDA Playground/Icarus behavioral simulations passed. No local Vivado, XSim, Questa, or Yosys executable was available, so Vivado-specific simulation, synthesis, implementation, and FPGA timing remain unverified.
- No FPGA board model/revision or target part was supplied. There are no board constraints, synthesis results, implementation results, resource estimates, or timing/frequency claims.
- The systolic dataflow test directly checks representative horizontal and vertical links and all boundary skew choices, plus all final outputs. It does not log/check every operand at every one of the sixteen PEs on every cycle.
- The top-level selector should remain stable during an operation. Inputs are assumed stable until completion.
- Only fixed 4×4 matrices are supported. UART, external memory, larger matrices, and board I/O are out of scope.
- The parallel and systolic designs use architecture-local result registers instead of the shared `output_storage`; their storage timing differs by design.
- Cycle counts and relative speedups come from behavioral simulation; they do not include measured operating frequency or hardware timing.
