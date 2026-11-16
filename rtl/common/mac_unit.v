// Combinational signed 16x16 MAC step. Product and sum widths are explicit.
module mac_unit (
    input wire signed [15:0] operand_a,
    input wire signed [15:0] operand_b,
    input wire signed [39:0] accumulator,
    output wire signed [39:0] result
);
    // Widen operands before multiply: the 32-bit signed result is unambiguous.
    wire signed [31:0] operand_a_ext = {{16{operand_a[15]}}, operand_a};
    wire signed [31:0] operand_b_ext = {{16{operand_b[15]}}, operand_b};
    wire signed [31:0] product = operand_a_ext * operand_b_ext;
    wire signed [39:0] product_ext = {{8{product[31]}}, product};
    assign result = accumulator + product_ext;
endmodule
