// 16-word, 40-bit result bank with synchronous clear and indexed write.
module output_storage (
    input wire clk, input wire reset, input wire write_enable,
    input wire [3:0] write_address, input wire signed [39:0] write_data,
    output wire [639:0] matrix_out
);
    reg signed [39:0] words [0:15];
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i=0;i<16;i=i+1) words[i] <= 40'sd0;
        end else if (write_enable) words[write_address] <= write_data;
    end
    genvar g;
    generate for (g=0;g<16;g=g+1) begin: PACK
        assign matrix_out[g*40 +: 40] = words[g];
    end endgenerate
endmodule
