`timescale 1ns/1ps
module tb_matrix_multiplier_top;
 reg clk=0,reset=0,start=0; reg [1:0] architecture=0; reg [255:0] a=0,b=0;
 wire busy,done; wire [31:0] cycles; wire [639:0] result,expected;
 integer errors=0,arch,t=0;
 always #5 clk=~clk;
 matrix_reference_model refmodel(a,b,expected);
 matrix_multiplier_top dut(clk,reset,start,architecture,a,b,busy,done,cycles,result);
 task run; input [1:0] mode; begin
  architecture=mode; a=256'h112233445566778899; b=256'h998877665544332211;
  @(negedge clk);start=1;@(negedge clk);start=0;t=0;
  while(done!==1 && t<100) begin @(negedge clk);t=t+1;end
  if(t>=100 || result!==expected) begin $display("TOP FAIL arch=%0d",mode);errors=errors+1;end
  else $display("TOP PASS arch=%0d cycles=%0d",mode,cycles);
 end endtask
 initial begin
  @(negedge clk);reset=1;@(negedge clk);reset=0;
  run(0);run(1);run(2);
  if(errors) begin $display("TOP SUMMARY FAIL errors=%0d",errors);$finish(1);end
  else begin $display("TOP SUMMARY PASS");$finish(0);end
 end
endmodule
