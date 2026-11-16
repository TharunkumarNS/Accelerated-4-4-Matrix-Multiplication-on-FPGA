`timescale 1ns/1ps
// Directed non-symmetric vectors and structural assertions for actual 16-PE dataflow.
module tb_systolic_dataflow;
 reg clk=0,reset=0,start=0; reg [255:0] a=0,b=0;
 wire busy,done; wire [31:0] cycles; wire [639:0] result,expected;
 integer r,c,n,errors=0,timeout;
 reg signed [15:0] prev_a,prev_b;
 always #5 clk=~clk;
 matrix_reference_model refmodel(a,b,expected);
 systolic_array dut(clk,reset,start,a,b,busy,done,cycles,result);
 // Verify registered transfer across real inter-PE links on every active clock.
 always @(posedge clk) begin
  prev_a=dut.ROW[0].COL[0].pe.a_out;
  prev_b=dut.ROW[0].COL[0].pe.b_out;
  #1;
  if(!reset && dut.ROW[0].COL[1].pe.a_out !== prev_a) begin
   $display("FAIL horizontal A propagation");errors=errors+1;
  end
  if(!reset && dut.ROW[1].COL[0].pe.b_out !== prev_b) begin
   $display("FAIL vertical B propagation");errors=errors+1;
  end
 end
 always @(negedge clk) if(dut.active) begin
  for(n=0;n<4;n=n+1) begin
   if(dut.phase>=n && dut.phase<n+4 && dut.ar[n] !== a[(n*4+(dut.phase-n))*16+:16]) begin
    $display("FAIL systolic A row skew row=%0d phase=%0d",n,dut.phase);errors=errors+1;
   end
   if(dut.phase>=n && dut.phase<n+4 && dut.bc[n] !== b[((dut.phase-n)*4+n)*16+:16]) begin
    $display("FAIL systolic B column skew col=%0d phase=%0d",n,dut.phase);errors=errors+1;
   end
  end
 end
 initial begin
  for(r=0;r<4;r=r+1) for(c=0;c<4;c=c+1) begin
   a[(r*4+c)*16+:16]=(r*7+c*3+1); b[(r*4+c)*16+:16]=(r*5-c*2+4);
  end
  @(negedge clk);reset=1;@(negedge clk);reset=0;start=1;@(negedge clk);start=0;
  timeout=0; while(done!==1 && timeout<30) begin
   @(negedge clk);timeout=timeout+1;
  end
  if(timeout>=30 || result!==expected) begin $display("SYSTOLIC FLOW FAIL result/alignment");errors=errors+1;end
  // Check propagation at a representative edge: rightward A and downward B registers
  // are directly connected in RTL; final numerical check exercises every PE's products.
  if(cycles!=11) begin $display("SYSTOLIC cycle count expected 11 got %0d",cycles);errors=errors+1;end
  if(errors) begin $display("SYSTOLIC DATAFLOW FAIL");$finish(1);end
  else begin $display("SYSTOLIC DATAFLOW PASS: 16 PE fabric, aligned products, cycles=%0d",cycles);$finish(0);end
 end
endmodule
