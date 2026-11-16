// Launches a 4x4 skewed wave and allows four drain cycles.
module systolic_controller(input wire clk,reset,start,
 output reg busy,done,output reg [31:0] cycle_count,
 output reg [3:0] phase,output reg clear_array,output reg active);
 reg priming;
 always @(posedge clk) begin
  if(reset) begin busy<=0;done<=0;cycle_count<=0;phase<=0;clear_array<=1;active<=0;priming<=0;end
  else begin done<=0;clear_array<=0;
   if(start&&!busy) begin busy<=1;active<=0;priming<=1;phase<=0;cycle_count<=0;clear_array<=1;end
   else if(busy && priming) begin active<=1;priming<=0;clear_array<=0; end
   else if(busy) begin cycle_count<=cycle_count+1;
    if(phase==10) begin busy<=0;active<=0;done<=1;end else phase<=phase+1;
   end
  end
 end
endmodule
