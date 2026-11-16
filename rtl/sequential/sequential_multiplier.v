// Single-MAC 4x4 signed matrix multiplier.
module sequential_multiplier(input wire clk, reset, start,
 input wire [255:0] matrix_a, matrix_b,
 output wire busy, done, output wire [31:0] cycle_count,
 output wire [639:0] result);
 wire [3:0] row,col; wire [1:0] k; wire clear_acc, write_result;
 reg signed [39:0] acc;
 wire signed [15:0] a = matrix_a[(row*4+k)*16 +:16];
 wire signed [15:0] b = matrix_b[(k*4+col)*16 +:16];
 wire signed [39:0] sum;
 reg [3:0] saved_address;
 always @(posedge clk) if(reset) saved_address<=0; else if(busy && k==3) saved_address<=row*4+col;
 mac_unit mac(a,b,acc,sum);
 output_storage store(clk,reset,write_result,saved_address,acc,result);
 sequential_controller ctrl(clk,reset,start,busy,done,row,col,k,cycle_count,clear_acc,write_result);
 always @(posedge clk) if(reset || clear_acc) acc<=40'sd0; else if(busy) acc<=sum;
endmodule
