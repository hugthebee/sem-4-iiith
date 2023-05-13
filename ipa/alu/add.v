`timescale 1ns/10ps

module ha(a, b, sum, carry);
input a, b;
output sum, carry;

xor xor1(sum, a, b);
and and1(carry, a, b);
endmodule

module fa(a, b, cin, sum, carry);
input a, b, cin;
output sum, carry;
wire w1, w2, w3;

xor xor1(w1, a, b);
xor xor2(sum, w1, cin);
and and1(w2, w1, cin);
and and2(w3, a, b);
or or1(carry, w2, w3);
endmodule

module add(a, b, out,cout);
input signed [63:0] a, b;
output signed [63:0] out;
output signed cout;
wire signed [63:0]carry;

genvar i;

generate 
for (i = 0; i < 64; i = i + 1)
begin
    if (i == 0)
        ha ha1(a[0], b[0], out[0], carry[0]);
    else
        fa fa1(a[i], b[i], carry[i - 1], out[i], carry[i]);
    end
    assign cout = carry[63];
endgenerate
endmodule