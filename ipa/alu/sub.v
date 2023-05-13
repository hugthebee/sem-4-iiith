`timescale 1ns/10ps
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

module sub(a, b, out, cout);
input signed [63:0] a, b;
output signed [63:0] out;
output signed cout;
wire signed [63:0]carry, temp;
wire signed xx;

assign xx = 1;

genvar p;
generate 
    for(p=0;p<=63;p=p+1)
    begin 
        not n1(temp[p],b[p]);   //temp = bitreveresed b
    end
endgenerate

genvar i;
generate 
for (i = 0; i < 64; i = i + 1)
begin
    if (i == 0)
        fa fa1(a[0], temp[0], xx, out[0], carry[0]);
    else
        fa fa1(a[i], temp[i], carry[i - 1], out[i], carry[i]);
    end
    assign cout = carry[63];
endgenerate
endmodule