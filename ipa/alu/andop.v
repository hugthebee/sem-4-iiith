`timescale 1ns/10ps

module andop(I1,I2,R);
input [63:0]I1;
input [63:0]I2;
output [63:0]R;

genvar i;
generate 
    for(i=0;i<64;i=i+1)
    begin
        and a0(R[i],I1[i],I2[i]);
    end
endgenerate
endmodule