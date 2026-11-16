// Four independent MACs compute one complete output row at a time.
module parallel_multiplier(input wire clk,reset,start,
 input wire [255:0] matrix_a,matrix_b,
 output wire busy,done,output wire [31:0] cycle_count,
 output wire [639:0] result);
 wire [1:0] row,k; wire clear_acc,write_row;
 reg signed [39:0] acc0,acc1,acc2,acc3;
 wire signed [39:0] s0,s1,s2,s3;
 wire signed [15:0] av=matrix_a[(row*4+k)*16 +:16];
 mac_unit m0(av,matrix_b[(k*4+0)*16 +:16],acc0,s0);
 mac_unit m1(av,matrix_b[(k*4+1)*16 +:16],acc1,s1);
 mac_unit m2(av,matrix_b[(k*4+2)*16 +:16],acc2,s2);
 mac_unit m3(av,matrix_b[(k*4+3)*16 +:16],acc3,s3);
 reg [639:0] outreg;
 reg [1:0] saved_row;
 always @(posedge clk) if(reset) saved_row<=0; else if(busy && k==3) saved_row<=row;
 assign result=outreg;
 always @(posedge clk) begin
  if(reset) begin acc0<=0;acc1<=0;acc2<=0;acc3<=0;outreg<=0;end
  else if(clear_acc) begin acc0<=0;acc1<=0;acc2<=0;acc3<=0;end
  else if(busy) begin acc0<=s0;acc1<=s1;acc2<=s2;acc3<=s3;end
  if(!reset && write_row) begin
   outreg[(saved_row*4+0)*40 +:40]<=acc0; outreg[(saved_row*4+1)*40 +:40]<=acc1;
   outreg[(saved_row*4+2)*40 +:40]<=acc2; outreg[(saved_row*4+3)*40 +:40]<=acc3;
  end
 end
 parallel_controller ctrl(clk,reset,start,busy,done,row,k,cycle_count,clear_acc,write_row);
endmodule
