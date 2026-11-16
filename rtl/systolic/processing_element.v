// Systolic PE: registered A moves right, B moves down; local signed MAC.
module processing_element(input wire clk,reset,clear,valid,
 input wire signed [15:0] a_in,b_in,
 output reg signed [15:0] a_out,b_out,
 output reg signed [39:0] accumulator);
 wire signed [31:0] a_ext={{16{a_in[15]}},a_in};
 wire signed [31:0] b_ext={{16{b_in[15]}},b_in};
 wire signed [31:0] product=a_ext*b_ext;
 wire signed [39:0] product_ext={{8{product[31]}},product};
 always @(posedge clk) begin
  if(reset) begin a_out<=0;b_out<=0;accumulator<=0;end
  else begin
   a_out<=a_in; b_out<=b_in;
   if(clear) accumulator<=0;
   else if(valid) accumulator<=accumulator+product_ext;
  end
 end
endmodule
