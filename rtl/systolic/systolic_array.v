// 4x4 systolic matrix multiplier. A enters by row, B by column, both skewed.
module systolic_array(input wire clk,reset,start,
 input wire [255:0] matrix_a,matrix_b,
 output wire busy,done,output wire [31:0] cycle_count,
 output wire [639:0] result);
 wire [3:0] phase; wire clear_array,active;
 wire signed [15:0] ar [0:3]; wire signed [15:0] bc [0:3];
 // Flattened net arrays keep this fabric compatible with Verilog-2001.
 wire signed [15:0] ah [0:15]; wire signed [15:0] bv [0:15];
 wire signed [39:0] accum [0:15];
 wire [15:0] valid_bits;
 genvar r,c;
 generate for(r=0;r<4;r=r+1) begin: ROW
  assign ar[r] = (active && phase>=r && phase<r+4) ? matrix_a[(r*4+(phase-r))*16 +:16] : 16'sd0;
  for(c=0;c<4;c=c+1) begin: COL
   assign bc[c] = (active && phase>=c && phase<c+4) ? matrix_b[((phase-c)*4+c)*16 +:16] : 16'sd0;
   wire signed [15:0] ain,bin;
   if(c==0) assign ain=ar[r]; else assign ain=ah[r*4+c-1];
   if(r==0) assign bin=bc[c]; else assign bin=bv[(r-1)*4+c];
   wire valid = (phase>=r+c) && (phase<r+c+4);
   assign valid_bits[r*4+c]=valid;
   processing_element pe(clk,reset,clear_array,valid,ain,bin,ah[r*4+c],bv[r*4+c],accum[r*4+c]);
  end
 end endgenerate
 reg [639:0] outreg; integer i,j;
 assign result=outreg;
 always @(posedge clk) begin
  if(reset) outreg<=0;
  else if(busy && phase==10) begin
   for(i=0;i<4;i=i+1) for(j=0;j<4;j=j+1) outreg[(i*4+j)*40 +:40]<=accum[i*4+j];
  end
 end
 systolic_controller ctrl(clk,reset,start,busy,done,cycle_count,phase,clear_array,active);
endmodule
