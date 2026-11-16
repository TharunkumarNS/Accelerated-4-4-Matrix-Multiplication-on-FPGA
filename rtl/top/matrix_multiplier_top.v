// Common top: architecture 00 sequential, 01 parallel, 10 systolic.
module matrix_multiplier_top(input wire clk,reset,start,input wire [1:0] architecture,
 input wire [255:0] matrix_a,matrix_b,
 output reg busy,done,output reg [31:0] cycle_count,output reg [639:0] result);
 wire sb,sd,pb,pd,yb,yd; wire [31:0] sc,pc,yc; wire [639:0] sr,pr,yr;
 sequential_multiplier seq(clk,reset,start && architecture==2'b00,matrix_a,matrix_b,sb,sd,sc,sr);
 parallel_multiplier par(clk,reset,start && architecture==2'b01,matrix_a,matrix_b,pb,pd,pc,pr);
 systolic_array sys(clk,reset,start && architecture==2'b10,matrix_a,matrix_b,yb,yd,yc,yr);
 always @* begin
  busy=0;done=0;cycle_count=0;result=0;
  case(architecture)
   2'b00: begin busy=sb;done=sd;cycle_count=sc;result=sr;end
   2'b01: begin busy=pb;done=pd;cycle_count=pc;result=pr;end
   2'b10: begin busy=yb;done=yd;cycle_count=yc;result=yr;end
   default: begin end
  endcase
 end
endmodule
