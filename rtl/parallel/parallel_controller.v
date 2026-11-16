// Four-term row engine schedule for four output rows.
module parallel_controller(input wire clk,reset,start,
 output reg busy,done, output reg [1:0] row,k,
 output reg [31:0] cycle_count, output reg clear_acc,write_row);
 reg active,finish_pending;
 always @(posedge clk) begin
  if(reset) begin active<=0;finish_pending<=0;busy<=0;done<=0;row<=0;k<=0;cycle_count<=0;clear_acc<=1;write_row<=0;end
  else begin done<=0;clear_acc<=0;write_row<=0;
   if(finish_pending) begin finish_pending<=0;active<=0;busy<=0;done<=1;cycle_count<=cycle_count+1;end
   else if(start&&!active) begin active<=1;busy<=1;row<=0;k<=0;cycle_count<=0;end
   else if(active) begin cycle_count<=cycle_count+1;
    if(clear_acc) begin end
    else begin
    if(k==3) begin k<=0;write_row<=1;clear_acc<=1;
     if(row==3) begin row<=0;finish_pending<=1;end else row<=row+1;
    end else k<=k+1;
    end
   end
  end
 end
endmodule
