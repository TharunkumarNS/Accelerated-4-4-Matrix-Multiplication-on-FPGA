// Independent behavioral reference. Packed row-major operands/results.
module matrix_reference_model(input wire [255:0] a,b, output reg [639:0] expected);
 integer i,j,k;
 reg signed [15:0] av,bv;
 reg signed [63:0] av_ext,bv_ext,product;
 reg signed [39:0] total;
 always @* begin
  expected=640'b0;
  for(i=0;i<4;i=i+1) for(j=0;j<4;j=j+1) begin
   total=40'sd0;
   for(k=0;k<4;k=k+1) begin
    av=a[(i*4+k)*16 +:16]; bv=b[(k*4+j)*16 +:16];
    av_ext={{48{av[15]}},av}; bv_ext={{48{bv[15]}},bv};
    product=av_ext*bv_ext;
    total=total+product[39:0];
   end
   expected[(i*4+j)*40 +:40]=total;
  end
 end
endmodule
