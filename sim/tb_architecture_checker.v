`timescale 1ns/1ps
// Shared self-checking case runner; each wrapper selects one independent DUT.
module tb_architecture_checker;
 parameter ARCH=0;
 reg clk=0, reset=0, start=0;
 // Nonzero initialization ensures the first all-zero case triggers the reference model.
 reg [255:0] a=256'h1,b=256'h1;
 wire busy,done; wire [31:0] cycles; wire [639:0] result,expected;
 integer tests=0, failures=0, timeout, seed;
 integer i;
 always #5 clk=~clk;
 matrix_reference_model refmodel(a,b,expected);
 generate if(ARCH==0) sequential_multiplier dut(clk,reset,start,a,b,busy,done,cycles,result);
 else if(ARCH==1) parallel_multiplier dut(clk,reset,start,a,b,busy,done,cycles,result);
 else if(ARCH==2) systolic_array dut(clk,reset,start,a,b,busy,done,cycles,result);
 endgenerate
 task reset_dut; begin
  @(negedge clk); reset=1; start=0; @(negedge clk); reset=0;
  if(busy!==0 || done!==0) begin $display("FAIL reset control ARCH=%0d",ARCH); failures=failures+1; end
 end endtask
 task run_case; input [255:0] aa,bb; begin
  a=aa;b=bb; #1;
  @(negedge clk); start=1; @(negedge clk); start=0;
  if(busy!==1) begin $display("FAIL busy did not assert ARCH=%0d",ARCH); failures=failures+1; end
  timeout=0;
  while(done!==1 && timeout<100) begin
   @(negedge clk); timeout=timeout+1;
   if(done===1'b1) begin
    if(busy!==1'b0) begin $display("FAIL busy not low with done ARCH=%0d",ARCH); failures=failures+1; end
   end else if(busy!==1'b1) begin
    $display("FAIL busy dropped before done ARCH=%0d",ARCH); failures=failures+1;
   end
  end
  if(timeout>=100) begin $display("FAIL timeout ARCH=%0d",ARCH); failures=failures+1; end
  else begin
   if(result !== expected) begin
    $display("FAIL result ARCH=%0d case=%0d cycles=%0d",ARCH,tests,cycles);
    for(i=0;i<16;i=i+1) if(result[i*40 +:40] !== expected[i*40 +:40])
     $display("  element[%0d] got=%h expected=%h",i,result[i*40 +:40],expected[i*40 +:40]);
    failures=failures+1;
   end
   if(^result===1'bx) begin $display("FAIL X/Z result ARCH=%0d",ARCH); failures=failures+1; end
   if(cycles==0) begin $display("FAIL zero cycles ARCH=%0d",ARCH); failures=failures+1; end
   if(ARCH==0 && cycles!=80) begin $display("FAIL sequential cycle count expected=80 got=%0d",cycles);failures=failures+1;end
   if(ARCH==1 && cycles!=20) begin $display("FAIL parallel cycle count expected=20 got=%0d",cycles);failures=failures+1;end
   $display("ARCH=%0d case=%0d cycles=%0d %s",ARCH,tests,cycles,(result===expected)?"PASS":"FAIL");
  end
  @(negedge clk); if(done!==0 || busy!==0) begin $display("FAIL done pulse/busy release ARCH=%0d",ARCH);failures=failures+1;end
  tests=tests+1;
 end endtask
 reg [255:0] x,y;
 initial begin
  seed=32'h45A19C31;
  reset_dut;
  // Zero, identity, ones, signed mix and signed input limits.
  x=0;y=0;run_case(x,y);
  x=0;y=0; for(i=0;i<4;i=i+1) begin x[(i*4+i)*16+:16]=16'd1; y[(i*4+i)*16+:16]=16'd1; end run_case(x,y);
  x={16{16'd1}};y={16{16'd1}};run_case(x,y);
  for(i=0;i<16;i=i+1) begin x[i*16+:16]=(i%2)?-16'sd17:16'sd23; y[i*16+:16]=(i%3)?-16'sd9:16'sd31; end run_case(x,y);
  for(i=0;i<16;i=i+1) begin x[i*16+:16]=(i%2)?16'sh8000:16'sh7fff; y[i*16+:16]=(i%2)?16'sh7fff:16'sh8000; end run_case(x,y);
  for(i=0;i<16;i=i+1) begin x[i*16+:16]=$random(seed); y[i*16+:16]=$random(seed); end run_case(x,y);
  // Start held high must launch only one operation; start while busy is ignored.
  a=0;b=0; @(negedge clk);start=1; @(negedge clk); if(!busy) failures=failures+1;
  repeat(3) @(negedge clk); start=0;
  timeout=0; while(done!==1 && timeout<100) begin @(negedge clk);timeout=timeout+1;end
  if(timeout>=100 || result!==expected) begin $display("FAIL held start ARCH=%0d",ARCH);failures=failures+1;end
  if(ARCH==0 && cycles!=80) begin $display("FAIL held-start cycle count ARCH=%0d cycles=%0d",ARCH,cycles);failures=failures+1;end
  if(ARCH==1 && cycles!=20) begin $display("FAIL held-start cycle count ARCH=%0d cycles=%0d",ARCH,cycles);failures=failures+1;end
  tests=tests+1;
  // Reset while an operation is active must abort without a stale done pulse.
  @(negedge clk); start=1; @(negedge clk);start=0; @(negedge clk); @(negedge clk);reset=1;
  @(negedge clk);reset=0; repeat(3) begin @(negedge clk); if(done!==0 || busy!==0) failures=failures+1; end
  // Back-to-back independent transactions.
  run_case(256'h1,256'h1); run_case(256'h2,256'h3);
  $display("ARCH=%0d SUMMARY tests=%0d failures=%0d",ARCH,tests,failures);
  if(failures) begin $display("REGRESSION FAIL ARCH=%0d",ARCH); $finish(1); end
  else begin $display("REGRESSION PASS ARCH=%0d",ARCH); $finish(0); end
 end
endmodule
